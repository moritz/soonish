use lib 'lib';
use Soonish::Schema;
use DBIish;
use Soonish::Album;
use Soonish::Concert;
use Soonish::Link;

my $s = Soonish::Schema.new(
    dbh => DBIish.connect('Pg', :host<localhost>, :user<soonish-dev>, :password(%*ENV<SOONISH_DB_PASSWORD>), :database<soonish-dev>, :RaiseError),
);

my $link = Soonish::Link.new(
    url  => 'http://www.markknopfler.com/tour/',
    text => 'Mark Knopfler on Tour',
    _schema => $s,
    entered-by => 'moritz',
);
$link.insert-or-update;
say "link id: $link.id()";

my $concert = Soonish::Concert.new(
    artist      => 'Mark Knopfler',
    date        => '2013-07-02',
    location    => 'Köln, Germany',
    entered-by  => 'moritz',
    link        => $link,
    _schema     => $s,
);
$concert.insert;

$s.dbh.disconnect;
