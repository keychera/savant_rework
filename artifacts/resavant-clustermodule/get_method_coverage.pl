#!/usr/bin/perl

=pod

=head1 NAME

get_method_coverage.pl -- get method-level coverage analysis of a project for given set of single tests

=head1 SYNOPSIS

get_method_coverage.pl -w working_directory -t single_test_list_file -i classes to instrument

=head1 OPTIONS

=over 4

=item -w F<ss>

Tss

=item -t F<ss>

Tss

=back

=cut
use warnings;
use strict;

use FindBin;
use File::Basename;
use Cwd qw(abs_path);
use Getopt::Std;
use Pod::Usage;

my $D4J_CORE;
BEGIN {
    unless (defined $ENV{D4J_HOME}) {
        die "D4J_HOME not set!\n";
    }
    $D4J_CORE = "$ENV{D4J_HOME}/framework/core";
}
use lib abs_path("$D4J_CORE");
use Constants;
use Coverage;
use Project;
use Utils;
use Log;
use DB;

# process arguments
my %cmd_opts;
getopts('w:t:i:', \%cmd_opts) or pod2usage( { -verbose => 1, -input => __FILE__} );

my $WORK_DIR = $cmd_opts{w};
my $SINGLE_TESTS = $cmd_opts{t};
my $INSTRUMENT = $cmd_opts{i};

# Get project reference from working directory
my $config = Utils::read_config_file("$WORK_DIR/$CONFIG");
unless(defined $config) {
    print(STDERR "$WORK_DIR is not a valid working directory!\n");
    exit 1;
}

my $project = Project::create_project($config->{$CONFIG_PID});
$project->{prog_root} = $WORK_DIR;

# get all single tests from file
-e $SINGLE_TESTS or die "Single test list file '$SINGLE_TESTS' does not exist!";
open FH, $SINGLE_TESTS;
my @single_tests = ();
{
    $/ = "\n";
    @single_tests = s/\R\z// for <FH>;
}
close FH;
my $single_test = $single_tests[1];

# run a single test
my $log_file = "$WORK_DIR/failing_tests";
$project->compile_tests() or die "Cannot compile tests!";
$project->run_tests($log_file, $single_test) or die "Cannot run the test! test attempted: $single_test";
