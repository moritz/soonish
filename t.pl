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
say "ID: ", $link.id;
$link.text = "Mark Knopfler's Tour plan";
$link.update;

$s.dbh.disconnect;
