package Controller;
use Text::Xslate;
my $tx = Text::Xslate->new(path => main::ROOT);
sub new {
        my ($class,$app) = @_;
        my $self = {
                        app => $app
                   };
        bless $self,$class;
        return $self;
}
sub render {
        my ($self,$vars) = @_;
        return $tx->render($self->{app}->{template}.".tx", $vars);
}
sub params {
        my ($self,$key) = @_;
        my $r = $self->{app}->{params};
        return ($key ? $r->{$key} : $r);
}
1;
