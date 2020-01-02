#!/usr/bin/perl

use warnings;
use strict;

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
use Project;

# process arguments
my %cmd_opts;
getopts('w:t:o:', \%cmd_opts) or pod2usage( { -verbose => 1, -input => __FILE__} );

my $WORK_DIR = abs_path($cmd_opts{w});
my $SINGLE_TEST = $cmd_opts{t};
my $OUTPUT_FILE = abs_path($cmd_opts{o});

# Instantiate project based on working directory
my $config = Utils::read_config_file("$WORK_DIR/$CONFIG");
unless(defined $config) {
    print(STDERR "$WORK_DIR is not a valid working directory!\n");
    exit 1;
}

my $project = Project::create_project($config->{$CONFIG_PID});
$project->{prog_root} = $WORK_DIR;

# ant call clover
$project->_ant_call("clean clover.clean");

if (defined $SINGLE_TEST) {
    my $single_test_opt = "";
    $SINGLE_TEST =~ /([^:]+)::([^:]+)/ or die "Wrong format for single test!";
    $single_test_opt = "-Dtest.entry.class=$1 -Dtest.entry.method=$2";
    $project->_ant_call("with.clover run.dev.test.clover", "$single_test_opt");
} else {
    $project->_ant_call("with.clover run.dev.test.clover");
}
$project->_ant_call("clover.xml", "-Dcoverage.xml.out=$OUTPUT_FILE");
