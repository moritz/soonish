use v6;
use Soonish::Table;

# TODO: Really need a better name for this;
role Soonish::Common does Soonish::Table {
    has $.entered-by;
#    has $.creation-date = now;
    # schould really be multiple links, but the "ORM" can't handle that yet
#    has $.link;
}

# vim: ft=perl6
