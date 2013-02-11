use v6;

role Soonish::Table {
    has Int $.id is rw;

    method !set_id($id) { $!id = $id }
    has $._schema;

    method table {
        self.^name.split('::')[*-1].lc;
    }

    method attributes {
        self.^attributes.map(*.Str.substr(2)).grep({ .substr(0,1) ne '_' }).map({; $_ => self."$_"()}).hash;
    }

    method insert-or-create() {
        self.id ?? self.update !! self.insert;
    }

    method insert() {
        my %a := self.attributes;
        my $id = %a.delete('id');
        if $id {
            die "Cannot insert an object that already has an id!";
        }
        my $dbh = $._schema.dbh;
        my @values = %a.values.map({ self.typemap($_) });
        my $sql = join ' ',
                    "INSERT INTO $dbh.quote-identifier($.table) ( ",
                    %a.keys.map({$dbh.quote-identifier($_)}).join(', '),
                    ') VALUES (',
                    ('?' xx %a.elems).join(', '),
                    ') RETURNING id';
        say $sql, '  ', @values.perl;
        my $sth = $dbh.prepare($sql);
        say "execute";
        $sth.execute(@values);
        say "fetchrow";
        $id = $sth.fetchrow[0].Int;
        $.id = $id;
        say "finish";
        $sth.finish;
        self;
    }

    method update() {
        my %a := self.attributes;
        my $id = %a.delete('id');
        unless $.id {
            die "Can only update an object that already has an id!";
        }
        my $dbh = $._schema.dbh;
        my @values = %a.values.map({ self.typemap($_) });
        my $sql = join ' ',
                    "UPDATE $dbh.quote-identifier($.table) SET ",
                    %a.keys.map({$dbh.quote-identifier($_) ~ " = ?"}).join(', '),
                    ' WHERE ',
                    $dbh.quote-identifier('id'),
                    ' = ?',
                    ;
        say join ' ', $sql, @values, $.id;
        my $sth = $dbh.prepare($sql);
        $sth.execute(@values, $.id);
        $sth.finish;
        self;
    }

    method insert-or-update() {
        $.id ?? $.update !! $.insert;
    }

    method typemap($obj) {
        if $obj ~~ Soonish::Table {
            $obj.id ?? $obj !! $obj.insert;
            $obj.id;
        }
        else {
            $obj;
        }
    }

}
