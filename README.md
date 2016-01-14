# Sensu plugin for monitoring Sensu stale check results

A sensu plugin to monitor sensu stale check results. You can then implement an handler that purges
the results after X days using the [sensu-handlers-purge-stale-results](http://github.com/m4ce/sensu-handlers-purge-stale-results) handler.

## Usage

The plugin accepts the following command line options:

```
Usage: check-stale-results.rb (options)
    -c, --crit <COUNT>               Critical if number of stale check results exceeds COUNT
    -s, --stale <TIME>               Elapsed time to consider a check result result (default: 1d)
    -v, --verbose                    Be verbose
    -w, --warn <COUNT>               Warn if number of stale check results exceeds COUNT (default: 1)
```

the --stale command line option accepts elapsed times formatted as documented in https://github.com/hpoydar/chronic_duration.

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
