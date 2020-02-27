use strict;
use warnings;

use Module::Build 0.3601;
use lib qw{inc}; use Alien::Base::ModuleBuild;

my %module_build_args = (
  "alien_build_commands" => [
    "%pautogen.sh",
    "%pconfigure --prefix=%s",
    "make",
  ],
  "alien_name" => "libgumbo",
  "alien_repository" => {
    "host" => "",
    "location" => "./",
    "pattern" => qr/(?:^libgumbo-([\d\.]+)\.tar\.gz$)/,
    "protocol" => "local",
  },
  "build_requires" => {},
  "configure_requires" => {
    "Alien::Base" => "0.002",
    "File::ShareDir" => "1.03",
    "Path::Class" => "0.013"
  },
  "dist_abstract" => "gumbo parser library",
  "dist_author" => [
    "Ruslan Zakirov <Ruslan.Zakirov\@gmail.com>"
  ],
  "dist_name" => "Alien-LibGumbo",
  "dist_version" => "0.02",
  "license" => "perl",
  "module_name" => "Alien::LibGumbo",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Alien::Base" => "0.002",
    "File::ShareDir" => "1.03",
    "Path::Class" => "0.013"
  },
  "script_files" => [],
  "test_requires" => {}
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Alien::Base::ModuleBuild->new(%module_build_args);

$build->create_build_script;
