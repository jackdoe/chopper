package Session;
use CGI::Cookie;
use Data::Dumper;
use Crypt::CBC;
use strict;
use warnings;

#use Sereal;
#my $decoder = Sereal::Decoder->new;
#my $encoder = Sereal::Encoder->new;

my $STORAGE = {}; #proof of concept 
my $CHIPER = new Crypt::CBC('my secret key','DES');
sub decrypt {
        my $s = shift;
        eval { 
                return $CHIPER->decrypt($s);
        } or do {
                return undef;
        }
}
sub encrypt {
        my $s = shift;
        return $CHIPER->encrypt($s);
}
use constant {
        SESSION_VALUE_LEN => 128,
        AZ => ['a'..'z','A'..'Z','0'..'9']
};

sub session_id {
        return join '', map { AZ->[rand @{+AZ}] } 1 .. SESSION_VALUE_LEN;
}

sub valid {
        my ($self,$app,$id) = @_;
        return 0 if !$id || length($id) != SESSION_VALUE_LEN;
        #if ($app->env('REQUEST_METHOD') != 'GET') {
        #        #validate referer for non-get requests
        #        return 0; 
        #}
        return 1;
}

sub generate_cookie {
        my ($self,$app,$args) = @_;
        return undef unless defined CONFIG->SESSION;
        my $key = CONFIG->SESSION->{key} || 'chop.session';
        my $cookie = CGI::Cookie->parse($app->env('HTTP_COOKIE'))->{$key};
        my $decrypted = $cookie ? Session::decrypt($app->sanitize($cookie->value)) : undef;
        if (!$cookie || !$self->valid($app,$decrypted)) {
                $decrypted = Session::session_id();
                $cookie = CGI::Cookie->new(-name => $key, -value => Session::encrypt($decrypted));
        }
        $app->header(-cookie => $cookie);
        return $cookie->value;
}
sub new {
        my ($class,$app) = @_;
        my $self = { app => $app, data => {}, id => undef};
        bless ($self,$class);

        $self->{id} = $self->generate_cookie($app);
        $self->load();
        return $self;
}

sub set {
        my ($self,$key,$value) = @_;
        $self->{data}->{$key} = $value;
        $self->save();
}

sub get {
        my ($self,$key) = @_;
        return $self->{data}->{$key}
}

sub destroy {
        my ($self) = @_;
        $self->{data} = {};
        $self->save();
}

sub save {
        my ($self) = @_;
        $STORAGE->{$self->{id}} = $self->{data} if defined $self->{id}; 
}

sub load {
        my ($self) = @_;
        if (defined $self->{id}) {
                $self->{data} = $STORAGE->{$self->{id}} || {} 
        } else {
                $self->{data} = {}
        }
}
1;
