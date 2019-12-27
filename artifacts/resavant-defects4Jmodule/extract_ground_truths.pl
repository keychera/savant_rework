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

# get defects4j project info
my $pid = $config->{$CONFIG_PID};
my $vid = $config->{$CONFIG_VID};
my $bid = Utils::check_vid($vid)->{bid};

my $identifier = "$pid.$vid";

# get the list of modified classes
my $mod_classes_list_file = "$OUTPUT_DIR/$identifier.list";
Utils::exec_cmd("$UTIL_DIR/get_modified_classes.pl -p $pid -b $bid > $mod_classes_list_file",
            "Exporting the set of modified classes");

-e $mod_classes_list_file or die "file '$mod_classes_list_file' does not exist!";
open my ($file_in), $mod_classes_list_file;

my @mod_classes = ();
while( my $line = <$file_in>)  {
    chomp($line);
    push @mod_classes, $line;
}

# get the class src paths
my $prop_file_path = "$WORK_DIR/defects4j.build.properties";

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
my $class_dir = "$WORK_DIR/$relative_class_dir";

my $buggy_classes_path = "$OUTPUT_DIR/$identifier.buggy_classes";
make_path($buggy_classes_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {
    my $class_name = "$mod_classes[$i]";
    my $class_rel_path = $class_name;
    $class_rel_path =~ s/\./\//g;
    $class_rel_path = "$class_rel_path.java";
    my $class_abs_path = "$class_dir/$class_rel_path";

    copy "$class_abs_path", "$buggy_classes_path/$class_name";
}

# get the source of fixed classes
my $fixed_src_path = "$OUTPUT_DIR/$identifier.fixed_src";
make_path($fixed_src_path);
Utils::exec_cmd("defects4j checkout -p $pid -v ${bid}f -w $fixed_src_path", 
            "Checking out the fixed source code");

my $class_dir = "$fixed_src_path/$relative_class_dir";

my $fixed_classes_path = "$OUTPUT_DIR/$identifier.fixed_classes";
make_path($fixed_classes_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {
    my $class_name = "$mod_classes[$i]";
    my $class_rel_path = $class_name;
    $class_rel_path =~ s/\./\//g;
    $class_rel_path = "$class_rel_path.java";
    my $class_abs_path = "$class_dir/$class_rel_path";

    copy "$class_abs_path", "$fixed_classes_path/$class_name";
}

# get which method is changed
my $JAVA = "$ENV{JAVA8}";
my $JAVA_CP = "$ENV{JAVAUTILS_JAR}";

my $method_diff_path = "$OUTPUT_DIR/$identifier.method_diff";
make_path($method_diff_path);
for (my $i = 0; $i < scalar @mod_classes; $i++) {

    my $buggy_class = "$buggy_classes_path/$mod_classes[$i]";
    my $fixed_class = "$fixed_classes_path/$mod_classes[$i]";
    my $method_diff_output = "$method_diff_path/$mod_classes[$i]";
    Utils::exec_cmd("$JAVA -cp $JAVA_CP resavant.utils.App $buggy_class $fixed_class > $method_diff_output",
                "Get MethodDiff between modified buggy classes and fixed classes");
}
