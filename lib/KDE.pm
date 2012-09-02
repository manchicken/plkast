package KDE;

sub get_kde_path {
  return $ENV{KDEHOME} || "$ENV{HOME}/.kde";
}

sub get_kde_config_path {
  return KDE->get_kde_path.'/share/config';
}

sub get_apps_path {
  return KDE->get_kde_path.'/share/apps';
}

1;
