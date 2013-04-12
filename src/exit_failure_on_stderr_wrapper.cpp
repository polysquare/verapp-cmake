/*
 * stderr_to_stderr_wrapper.cpp
 * Launches the first argument, watches the stderr. If there
 * is any output, save the output, print it to stderr and then
 * exit with failure. Otherwise exists with success
 *
 *
 * See LICENCE.md for Copyright information
 */

#include <iostream>
#include <sstream>
#include <system_error>

#include <boost/iostreams/device/file_descriptor.hpp>
#include <boost/iostreams/stream.hpp>

#include <unistd.h>
#include <cstring>

#include <fcntl.h>

#include <sys/types.h>
#include <sys/wait.h>

namespace bio = boost::iostreams;

namespace
{
    int usage ()
    {
        std::cout << "usage: stderr_to_stderr_wrapper BINARY"
                  << std::endl;
        return 1;
    }

    class Pipe
    {
        public:

            Pipe ();
            ~Pipe ();

            int ReadEnd ();
            int WriteEnd ();

            void CloseReadEnd ();
            void CloseWriteEnd ();

        private:

            int pipe[2];

            Pipe (Pipe const &) = delete;
            Pipe & operator= (Pipe const &) = delete;
    };
}

Pipe::Pipe ()
{
    if (pipe2 (pipe, O_CLOEXEC) == -1)
    {
        std::error_code code (errno,
                              std::system_category ());
        throw std::system_error (code);
    }
}

Pipe::~Pipe ()
{
    CloseReadEnd ();
    CloseWriteEnd ();
}

int Pipe::ReadEnd ()
{
    return pipe[0];
}

int Pipe::WriteEnd ()
{
    return pipe[1];
}

void Pipe::CloseReadEnd ()
{
    if (pipe[0])
    {
        close (pipe[0]);
        pipe[0] = 0;
    }
}

void Pipe::CloseWriteEnd ()
{
    if (pipe[1])
    {
        close (pipe[1]);
        pipe[1] = 0;
    }
}

int main (int argc, char *argv[])
{
    if (argc < 2)
        return usage ();

    Pipe stderrPipe;

    /* Save stderr */
    int stderr = dup (STDERR_FILENO);

    if (stderr == -1)
    {
        std::error_code code (errno,
                              std::system_category ());
        throw std::system_error (code);
    }

    /* Drop reference */
    if (close (STDERR_FILENO) == -1)
    {
        std::error_code code (errno,
                              std::system_category ());
        throw std::system_error (code);
    }

    /* Make the pipe write end our stderr */
    if (dup2 (stderrPipe.WriteEnd (), STDERR_FILENO) == -1)
    {
        std::error_code code (errno,
                              std::system_category ());
        throw std::system_error (code);
    }

    pid_t child = fork ();

    /* Child process */
    if (child == 0)
    {
        if (execvpe (argv[1],
                     &argv[1],
                     environ) == -1)
        {
            std::error_code code (errno,
                                  std::system_category ());
            throw std::system_error (code);
        }
    }
    /* Parent process, error */
    else if (child == -1)
    {
        std::error_code code (errno,
                              std::system_category ());
        throw std::system_error (code);
    }
    /* Parent process */
    else
    {
        /* Redirect old stderr back to stderr */
        if (dup2 (stderr, STDERR_FILENO) == -1)
        {
            std::error_code code (errno,
                                  std::system_category ());
            throw std::system_error (code);
        }

        /* Close the write end of the pipe - its being
         * used by the child */
        stderrPipe.CloseWriteEnd ();

        int status = 0;

        do
        {
            pid_t waitChild = waitpid (child, &status, 0);
            if (waitChild == child)
            {
                if (WIFSIGNALED (status))
                {
                    std::stringstream ss;
                    ss << "child killed by signal "
                       << WTERMSIG (status);
                    throw std::runtime_error (ss.str ());
                }
            }
            else
            {
                std::error_code code (errno,
                                      std::system_category ());
                throw std::system_error (code);
            }
        } while (!WIFEXITED (status) && !WIFSIGNALED (status));

        typedef bio::stream_buffer <bio::file_descriptor_source>  ChildStream;
        ChildStream streambuf (stderrPipe.ReadEnd (), bio::never_close_handle);

        std::vector <std::string> lines;

        std::istream stream (&streambuf);
        while (stream)
        {
            std::string line;
            std::getline (stream, line);
            if (!line.empty ())
                lines.push_back (line);
        }

        for (auto const &line : lines)
            std::cerr << line << std::endl;

        if (!lines.empty ())
            return 1;
        else
            return 0;
    }

    return 1;
}
