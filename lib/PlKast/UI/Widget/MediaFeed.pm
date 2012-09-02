use strict;

package PlKast::UI::Widget::MediaFeed;
use Qt;
use Qt::isa qw(Qt::ListViewItem);
use Qt::attributes qw(pData);

sub NEW {
  shift->SUPER::NEW(@_[0..2]);
}

sub setData {
  my ($data) = @_;

  pData = $data;
}

sub getData {
  my ($self) = @_;

  return pData;
}

sub getText {
  return text(0);
}

sub getId {
  return pData->{-id};
}

sub getTitle {
  return pData->{-title};
}

sub getUrl {
  return pData->{-url};
}

1;
