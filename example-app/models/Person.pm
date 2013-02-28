package Person;
sub new {
        my ($class,$dbh) = @_;
        my $self = {};
        bless $self,$class;
        return $self;
}
sub list {
        return CONFIG::DBH->selectall_arrayref("SELECT name FROM people",{Slice => {}})        
}
sub add {
        my ($name) = @_;
        my $s = CONFIG::DBH->prepare(qq{INSERT INTO people(name) VALUES(?)});
        $s->execute($name);
        $s->finish();
        return $s;
}
1;
