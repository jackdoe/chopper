package PersonController;
our @ISA = qw(Controller);
sub index {
        my ($self,$app,$session) = @_;
        $count = int($session->get('count')) + 1;
        $session->set('count',$count);
        return $self->render({ 
                                title => 'A list of people',
                                people => Person::list(),
                                count => $count
                            });
}
sub add {
        my ($self,$app,$session) = @_;
        
        my $name = $self->params('name');
        Person::add($name);
        return $app->redirect('/person/index/');
}
1;
