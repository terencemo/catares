#!/usr/bin/perl

#my $dsn = "dbi:mysql:mladb";
use lib 'lib';
use catares::Schema;
use SQL::Translator;

my ( $ver ) = @ARGV;

$ver ||= "0.044";

my $schema = catares::Schema->connect("dbi:mysql:catares", "catares", "catares");
my $dir = './sql';
$schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
                        $ver,
                        $dir
                        );

opendir(DIR, $dir);
my $newfile;
foreach my $file (grep { m/catares-Schema-$ver-\w+.sql/ } readdir(DIR)) {
    ( $newfile = $file ) =~ s/$ver/latest/;
    if (-l "$dir/$newfile") {
        unlink "$dir/$newfile";
    }
    symlink("$file", "$dir/$newfile");
}
closedir(DIR);

