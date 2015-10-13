# TODO

- Formatter/reporting should work more sensibly to allow any formatter to be used.
- Clean up the communication between the server and workers. It's messy and not very well structured in the code.
- Come up with a sensible way of testing the interaction between the server and workers.
- Add retry to workers so they'll re-attempt to connect to the server a few times.
- Add timeouts to workers so they'll give up eventually if the server disappears.
- Separate the worker spawning code from the server rspec runner.
- Potentially switch to TCPSocket to allow workers on other machines to communicate with the server.
- Consider providing some rake tasks to perform various helpful tasks like cloning databases.
- Suppress filter output in workers to reduce noise
