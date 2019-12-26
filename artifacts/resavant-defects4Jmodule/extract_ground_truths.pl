#!/usr/bin/perl

=pod

=head1 NAME

extract_ground_truths.pl -- TODO description
=head1 SYNOPSIS

extract_ground_truths.pl -w working_directory

=head1 OPTIONS

=over 4

=item -w F<ss>

Tss

=item -t F<ss>

Tss

=item -i F<ss>

Tss

=item -o F<ss>

Tss

=back

=cut
use warnings;
use strict;

use FindBin;
use File::Basename;
use File::Path qw(make_path);
use Cwd qw(abs_path);
use Getopt::Std;
use Pod::Usage;

my $D4J_HOME;
BEGIN {
    unless (defined $ENV{D4J_HOME}) {
        die "D4J_HOME not set!\n";
    }
    $D4J_HOME = "$ENV{D4J_HOME}";
}
use lib abs_path("$D4J_HOME/framework/core");
use Constants;
use Coverage;
use Project;
use Utils;

# process arguments
my %cmd_opts;
getopts('w:t:i:o:', \%cmd_opts) or pod2usage( { -verbose => 1, -input => __FILE__} );

my $WORK_DIR = $cmd_opts{w};
my $OUTPUT_DIR = $cmd_opts{o};

# Instantiate project based on working directory
my $config = Utils::read_config_file("$WORK_DIR/$CONFIG");
unless(defined $config) {
    print(STDERR "$WORK_DIR is not a valid working directory!\n");
    exit 1;
}

my $project = Project::create_project($config->{$CONFIG_PID});
$project->{prog_root} = $WORK_DIR;

# temp ref
my $pid = $config->{$CONFIG_PID};
my $vid = $config->{$CONFIG_VID};
my $bid = Utils::check_vid($vid)->{bid};
my $type = Utils::check_vid($vid)->{type};

# get which class is modified
my $mod_classes_list_file = "$OUTPUT_DIR/$bid.list";
Utils::exec_cmd("$UTIL_DIR/get_modified_classes.pl -p $pid -b $bid > $mod_classes_list_file",
            "Exporting the set of modified classes");

-e $mod_classes_list_file or die "file '$mod_classes_list_file' does not exist!";
open my ($file_in), $mod_classes_list_file;

my @mod_classes = ();
while( my $line = <$file_in>)  {
    chomp($line);
    push @mod_classes, $line;
}



# get the source of the buggy class
my $prop_file_path = "$WORK_DIR/defects4j.build.properties";

-e $prop_file_path or die "file $prop_file_path does not exist!";
open my ($prop_file), $prop_file_path;

my $found;
my $val;
while(my $line = <$prop_file>)  {
    chomp($line);
    $found = ($line =~ m/d4j\.dir\.src\.classes=(.*)/);
    if ($found) {
        $val = $1;
    }
    last if $found;
}

print("src path: $val\n");

my $buggy_path = "$OUTPUT_DIR/$bid.fixed";
make_path($buggy_path);

for (my $i = 0; $i < scalar @mod_classes; $i++) {

}

# get which method is changed

# print to file
