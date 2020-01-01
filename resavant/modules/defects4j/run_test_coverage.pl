#!/usr/bin/perl

=pod

=head1 NAME

run_test_coverage.pl -- get method-level coverage analysis of a project for given set of single tests

=head1 SYNOPSIS

run_test_coverage.pl -w working_directory -t single_test_list_file -i classes_to_instrument -o output_path

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

my $SER_FILE = "cobertura.ser";
my $CORBETURA_REPORT = "$SCRIPT_DIR/projects/lib/cobertura-report.sh";

# process arguments
my %cmd_opts;
getopts('w:t:i:o:', \%cmd_opts) or pod2usage( { -verbose => 1, -input => __FILE__} );

my $WORK_DIR = abs_path($cmd_opts{w});
my $SINGLE_TESTS_FILE = $cmd_opts{t};
my $INSTRUMENT = $cmd_opts{i};
my $OUTPUT_PATH = abs_path(($cmd_opts{o});

# Instantiate project based on working directory
my $config = Utils::read_config_file("$WORK_DIR/$CONFIG");
unless(defined $config) {
    print(STDERR "$WORK_DIR is not a valid working directory!\n");
    exit 1;
}

my $project = Project::create_project($config->{$CONFIG_PID});
$project->{prog_root} = $WORK_DIR;

# Instrument all classes provided
$project->coverage_instrument($INSTRUMENT) or die("Can't instrument project!");

# get all single tests from file
-e $SINGLE_TESTS_FILE or die "Single test list file '$SINGLE_TESTS_FILE' does not exist!";
open my ($file_in), $SINGLE_TESTS_FILE;

my @single_tests = ();
while( my $line = <$file_in>)  {
    chomp($line);
    push @single_tests, $line;
}

close $file_in;
die "No single tests found in the file!" if scalar @single_tests == 0;

# loop the tests and run each one
$project->compile_tests() or die "Cannot compile tests!";
for (my $i = 0; $i < scalar @single_tests; $i++) {
    # prepare the output location
    my $out_folder = "$OUTPUT_PATH/$i";
    make_path($out_folder);

    my $log_file = "$out_folder/failing_tests";
    open my $dummy, ">", "$log_file" or die "can't create file: $log_file";

    # run the test
    my $single_test = $single_tests[$i];
    print "\ntesting for $single_test\n";
    $project->run_tests($log_file, $single_test) or die "Cannot run the test! test attempted: $single_test";

    # do coverage report
    my $ser_path = "$WORK_DIR/$SER_FILE";
    my $report_folder = "$out_folder/cobertura";
    make_path($report_folder);
    system("sh $CORBETURA_REPORT --format xml --datafile $ser_path --destination $report_folder >/dev/null 2>&1") == 0 or die "could not create report";
    #make_path("$report_folder/html");
    #system("sh $CORBETURA_REPORT --format html --datafile $ser_path --destination $report_folder/html >/dev/null 2>&1") == 0 or die "could not create report";
}
