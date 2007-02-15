use strict;

# Submits the display name and GO term projections as farm jobs
# Remember to check/set the various config optons

# ------------------------------ config -------------------------------
my $release = 43;

my $base_dir = "/lustre/work1/ensembl/gp1/projections/";

my $conf = "release_43.conf"; # registry config file

my $compara = "ensembl_compara_43"; # name in registry file

# -------------------------- end of config ----------------------------

# check that base directory exists
die ("Cannot find base directory $base_dir") if (! -e $base_dir);

# create release subdir if necessary
my $dir = $base_dir. $release;
if (! -e $dir) {
  mkdir $dir;
  print "Created $dir\n";
} else {
  print "Cleaning and re-using $dir\n";
  unlink <$dir/*.out>, <$dir/*.err>;
}

# common options
my $opts = "-conf $conf -compara $compara -release $release";

my ($o, $e, $n);

# ----------------------------------------
# Display names

# human to chimp,opossum,dog,cow,macaque,chicken,xenopus
foreach my $to ("chimp", "opossum", "dog", "cow", "macaque", "chicken", "xenopus") {
  $o = "$dir/names_human_$to.out";
  $e = "$dir/names_human_$to.err";
  $n = substr("n_hum_$to", 0, 10); # job name display limited to 10 chars
  system "bsub -o $o -e $e -J $n perl project_display_xrefs.pl $opts -from human -to $to -names -delete_names";
}
exit(0);

# mouse to rat
foreach my $to ("rat") { # don't need the loop but may add more species later
  $o = "$dir/names_mouse_$to.out";
  $e = "$dir/names_mouse_$to.err";
  $n = substr("n_mou_$to", 0, 10);
  system "bsub -o $o -e $e -J $n perl project_display_xrefs.pl $opts -from human -to $to -names -delete_names";
}

# ----------------------------------------
# GO terms

$opts .= " -nobackup";

# human to mouse, rat, dog, chicken, cow
foreach my $to ("mouse", "rat", "dog", "chicken", "cow") {
  $o = "$dir/go_human_$to.out";
  $e = "$dir/go_human_$to.err";
  $n = substr("g_hum_to", 0, 10);
  system "bsub -o $o -e $e perl project_display_xrefs.pl $opts -from human -to $to -go_terms -delete_go_terms";
}

# mouse to human, rat, dog, chicken, cow
# note need to not use -delete the second time around
foreach my $to ("human", "rat", "dog", "chicken", "cow") {
  $o = "$dir/go_mouse_$to.out";
  $e = "$dir/go_mouse_$to.err";
  $n = substr("g_mou_$to", 0, 10);
  system "bsub -o $o -e $e perl project_display_xrefs.pl $opts -from mouse -to $to -go_terms";
}

# drosophila to anopheles
$o = "$dir/go_drosophila_anopheles.out";
$e = "$dir/go_drosophila_anopheles.err";
$n = "g_dros_ano";
system "bsub -o $o -e $e perl project_display_xrefs.pl $opts -from drosophila -to anopheles -go_terms -delete_go_terms";
