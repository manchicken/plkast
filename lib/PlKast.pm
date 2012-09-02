use strict;

package PlKast;
use Qt;
use Qt::isa qw/Qt::Object/;
use Qt::attributes qw/opts/;
use Qt::slots
	plkastClosing => [];

use Error qw/:try/;

use KDE;

sub _get_rcfile {
  return KDE->get_kde_config_path.'/plkastrc';
}

sub _get_configdir {
  my $config_dir = KDE->get_apps_path.'/plkast';
  if (!(-d $config_dir)) {
    mkdir($config_dir, 0700) ||
      throw Error::Simple("Failed to make config dir: $!");
  }

  return $config_dir;
}

sub _get_data_file_name {
  my ($group) = @_;
  return this->_get_configdir."/".$group;
}

sub NEW {
	my ($class, $parent, $name, %opts) = @_;

	if (defined($parent) && ref($parent) && $parent->isa('Qt::Object') && !ref($name)) {
		$class->SUPER::NEW($parent, $name);
	} else {
		$class->SUPER::NEW();
	}

	opts = \%opts;
}

1;
