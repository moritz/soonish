use v6;
use Soonish::Common;

class Soonish::Link does Soonish::Common {
    # TODO: also implement local links
    has $.url;
    has $.text is rw;
}
