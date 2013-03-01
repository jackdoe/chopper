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
        my $r = $self->{app}->{cgi};
        use Data::Dumper;
        print Dumper({$r->Vars});
        return ($key ? $r->param($key) : {$r->Vars});
}
1;
