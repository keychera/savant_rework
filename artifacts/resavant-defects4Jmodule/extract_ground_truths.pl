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

# get which class is modified
Utils::exec_cmd("$UTIL_DIR/get_modified_classes.pl -p $pid -b $bid > $OUTPUT_DIR/$bid.src",
            "Exporting the set of modified classes");

# fet the source of the class, before and after

# get which method is changed

# print to file
