package PersonController;
our @ISA = qw(Controller);
sub index {
        my ($self,$app,$session) = @_;

        $session->set('x','123123');
        return $self->render({ 
                                title => 'A list of people',
                                people => Person::list()
                            });
}
sub add {
        my ($self,$app,$session) = @_;
        
        my $name = $self->params('name');
        Person::add($name);
        return $app->redirect('/person/index/');
}
1;
