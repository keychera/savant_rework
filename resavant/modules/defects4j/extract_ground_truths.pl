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
use File::Copy qw(copy);
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
getopts('w:p:v:o:', \%cmd_opts) or pod2usage( { -verbose => 1, -input => __FILE__} );

my $WORK_DIR = $cmd_opts{w};
my $OUTPUT_DIR = $cmd_opts{o};
my $pid = $cmd_opts{p};
my $vid = $cmd_opts{v};

my $identifier = "$pid.$vid";
my $bid = substr $vid, 0, -1;

# get the list of modified classes
my $mod_classes_list_file = "$OUTPUT_DIR/$identifier.mod_classes_list";
Utils::exec_cmd("$UTIL_DIR/get_modified_classes.pl -p $pid -b $bid > $mod_classes_list_file",
            "Exporting the set of modified classes\n");

-e $mod_classes_list_file or die "file '$mod_classes_list_file' does not exist!";
open my ($file_in), $mod_classes_list_file;

my @mod_classes = ();
while( my $line = <$file_in>)  {
    chomp($line);
    push @mod_classes, $line;
}

# get the class src paths
my $prop_file_path = "$WORK_DIR/b/defects4j.build.properties";

-e $prop_file_path or die "file $prop_file_path does not exist!";
open my ($prop_file), $prop_file_path;

my $found;
my $relative_class_dir;
while(my $line = <$prop_file>)  {
    chomp($line);
    $found = ($line =~ m/d4j\.dir\.src\.classes=(.*)/);
    if ($found) {
        $relative_class_dir = $1;
    }
    last if $found;
}

# get the source of the buggy classes
my $buggy_class_dir = "$WORK_DIR/b/$relative_class_dir";

my $buggy_classes_path = "$OUTPUT_DIR/$identifier.buggy_classes";
make_path($buggy_classes_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {
    my $class_name = "$mod_classes[$i]";
    my $class_rel_path = $class_name;
    $class_rel_path =~ s/\./\//g;
    $class_rel_path = "$class_rel_path.java";
    my $class_abs_path = "$buggy_class_dir/$class_rel_path";

    copy "$class_abs_path", "$buggy_classes_path/$class_name";
}

# get the source of fixed classes
my $fixed_class_dir = "$WORK_DIR/f/$relative_class_dir";

my $fixed_classes_path = "$OUTPUT_DIR/$identifier.fixed_classes";
make_path($fixed_classes_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {
    my $class_name = "$mod_classes[$i]";
    my $class_rel_path = $class_name;
    $class_rel_path =~ s/\./\//g;
    $class_rel_path = "$class_rel_path.java";
    my $class_abs_path = "$fixed_class_dir/$class_rel_path";

    copy "$class_abs_path", "$fixed_classes_path/$class_name";
}

# get which method is changed
# TODO not yet error handle these ENV var
my $JAVA = "$ENV{JAVA8}";
my $JAVA_CP = "$ENV{SCRIPTS_JAVA_JAR}";

my $method_diff_path = "$OUTPUT_DIR/$identifier.method_diff";
make_path($method_diff_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {

    my $buggy_class = "$buggy_classes_path/$mod_classes[$i]";
    my $fixed_class = "$fixed_classes_path/$mod_classes[$i]";
    my $method_diff_output = "$method_diff_path/$mod_classes[$i]";
    Utils::exec_cmd("$JAVA -cp $JAVA_CP resavant.utils.MethodDiff $buggy_class $fixed_class > $method_diff_output",
                "Get MethodDiff between modified buggy classes and fixed classes\n");
    
    -e $method_diff_output or die "file $method_diff_output does not exist!";
    open my ($method_diff_file), $method_diff_output;

    my @formatted_methods = ();
    while(my $line = <$method_diff_file>)  {
        chomp($line);
        $line =~ m/.*\.(.*)\(.*\)/;
        my $method_name = $1;
        my $class_name = $mod_classes[$i];
        my $formatted_name = "$class_name\:\:$method_name";
        push @formatted_methods, $formatted_name;
    }

    open(to_write, '>', $method_diff_output) or die "file $method_diff_output does not exist";
    
    for (my $i = 0; $i < scalar @formatted_methods; $i++) {
        print to_write $formatted_methods[$i];
    }
}
