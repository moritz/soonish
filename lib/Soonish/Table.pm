use v6;

role Soonish::Table {
    has Int $.id;
    has $._table;
    has $._schema;

    method attributes {
        self.^attributes.grep({ .name.substr(0,1) ne '_' }).map({; $.name => self."$_.name()"()}).hash;
    }

    method insert-or-create(Bool :$recursive) {
        self.id ?? self.update(:$recursive) !! self.insert(:$recursive)
    }

    method insert(Bool :$recursive) {
        my %a := self.attributes;
        my $id = %a.delete('id');
        unless $id {
            die "Cannot insert an object that already has an id!";
        }
        my $dbh = $._schema.dbh;
        my $sql = join ' ',
                    "INSERT INTO $dbh.quote-identifier($.table) ( ",
                    %a.keys.map({$dbh.quote-identifier($_)}).join(', '),
                    ') VALUES (',
                    ('?' xx %a.elems).join(', '),
                    ') RETURNING id';
        my $sth = $dbh.prepare($sql);
        if $recursive {
            $sth.execute(%a.values.map({ $_ ~~ Soonish::Table ?? .insert-or-update(:recursive).id !! $_ }));
        }
        else {
            $sth.execute(%a.values.map({ $_ ~~ Soonish::Table ?? .id || .insert.id  !! $_}));
        }
        ($id) = $sth.fetchrow;
        $sth.finish;
        $.id = $id;
        self;
    }

    method update(Bool :$recursive) {
        my %a := self.attributes;
        my $id = %a.delete('id');
        unless $id.defined && $id != 0 {
            die "Can only update an object that already has an id!";
        }
        my $dbh = $._schema.dbh;
        my $sql = join ' ',
                    "UPDATE $dbh.quote-identifier($.table) ( ",
                    %a.keys.map({$dbh.quote-identifier($_)}).join(', '),
                    ') VALUES (',
                    ('?' xx %a.elems).join(', '),
                    ')';
        my $sth = $dbh.prepare($sql);
        if $recursive {
            $sth.execute(%a.values.map({ $_ ~~ Soonish::Table ?? (.insert-or-update.id)  !! $_ } ));
        }
        else {
            $sth.execute(%a.values.map({ $_ ~~ Soonish::Table ?? (.id || .insert.id)  !! $_ } ));
        }
        $sth.finish;
        self;
    }
}