package Application;
use CGI;
use File::Spec;
use strict;
use warnings;
sub new {
        my $class = shift;
        my ($args) = @_;
        my $params = {CGI->new($args->{in})->Vars,CGI->new($args->{env}->{QUERY_STRING})->Vars};
        my $self = { 
                        params => $params, 
                        env => $args->{env},
                        debug => $args->{debug},
                   };
        bless ($self,$class);
        $self->reset();
        $self->{session} = Session->new($self);
        return $self;
}
sub reset {
        my ($self) = @_;
        $self->{_output} = "";
        $self->{_header} = {};
}

sub redirect {
        my ($self,$where) = @_;
        $self->reset();
        $self->header(-status => 301, -location => $where);
        return "";
}

sub header {
        my $self = shift;
        $self->{_header} = {%{$self->{_header}}, @_};
}

sub say {
        my ($self,$m) = @_;
        $self->{_output} .= "$m" if $m;
        return 1;
}

sub error {
        my ($self,$code,$message,$debug) = @_;
        $self->reset();
        $self->header(-status=> $code);
        $self->say($message);
        $self->say(" [ $debug ] ") if $debug && $self->{debug} > 0;
        my ($package, $filename, $line) = caller;
        die "$filename:$line { $package } $message";
}

sub env {
        my ($self,$key) = @_;
        return $self->{env}->{$key};
}

sub route {
        my ($self) = @_;
        my $a = CONFIG::ROUTE->{$self->env('REQUEST_METHOD')};
        if ($a) {
                my $uri = $self->env('DOCUMENT_URI');
                for my $re(keys(%{$a})) {
                        my @m = ($uri =~ $re);
                        return $a->{$re},@m if @m;
                }
        }
        return (undef);
}
sub sanitize {
        my ($self,$s) = @_;
        $s =~ s/[^a-zA-Z0-9_-]//;
        return $s;
}
sub process {
        my ($self) = @_;
        eval {
                my ($r,@matches) = $self->route(); 
                if ($r) {
                        my $ref = ref($r);
                        my $code = undef;
                        if ($ref eq 'CODE') {
                                $code = $r;
                                $self->{template} = undef;
                        } elsif ($ref eq 'ARRAY') {
                                my ($controller, $method) = @{$r};
                                $self->{template} = File::Spec->join('app', 'views',$self->sanitize($controller),$self->sanitize($method));
                                eval {
                                        $controller .= "Controller";
                                        $controller = $controller->new($self);
                                        $code = sub { $controller->$method(@_) };
                                } or do {
                                        $self->error(500,"unable to load controller '$controller'",$@);
                                };
                        } else {
                                $self->error(500,"undefined reference type: $ref");
                        }
                        eval { $self->say(&$code($self,$self->{session},@matches)); } or do { $self->error(500,"undefined error",$@) };
                } else {
                        $self->error(404,$self->env('DOCUMENT_URI') . " not found");
                }
        } or do {
                warn "eval: $@" if $self->{debug} > 0;
        };
        warn $self->env('REMOTE_ADDR') . " - " . $self->env('REQUEST_URI') . " body: ".length($self->{_output})." bytes\n" if $self->{debug} > 0;
        return CGI::header($self->{_header}) . $self->{_output};
}

1;
