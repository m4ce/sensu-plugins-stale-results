# Sensu plugin for monitoring Sensu stale check results

A sensu plugin to monitor sensu stale check results. You can then implement an handler that purges
the results after X occurences.

## Usage

The plugin accepts the following command line options:

```
Usage: check-stale-results.rb (options)
    -c, --crit <COUNT>               Critical if number of stale check results exceeds COUNT
    -s, --stale <SECONDS>            Number of seconds to consider a check result stale (default: 86400)
    -v, --verbose                    Be verbose
    -w, --warn <COUNT>               Warn if number of stale check results exceeds COUNT (default: 1)
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
