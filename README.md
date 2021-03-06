<img src="docs/excelsieur-logo.png" width="480">

[![pipeline status](https://git.panter.ch/open-source/excelsieur/badges/master/pipeline.svg)](https://git.panter.ch/open-source/excelsieur/commits/master)
[![Gem Version](https://badge.fury.io/rb/excelsieur.svg)](https://badge.fury.io/rb/excelsieur)
[![Maintainability](https://api.codeclimate.com/v1/badges/657ecb9ccf29186a1377/maintainability)](https://codeclimate.com/github/panter/excelsieur/maintainability)

---

A straightforward way to import data from an excel sheet into your ruby app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'excelsieur'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install excelsieur

## How to use it

Create a class which declares how columns from an excel sheet map to your ruby object model by extending from the `Excelsieur::Importer` class:

```ruby
class UserImporter < Excelsieur::Importer
  # declare the source file
  source "static/ftp/users.xlsx"

  # declare the mapping
  map "First Name", to: :firstname
  map "Last Name", to: :lastname
  map "E-Mail", to: :email
end
```

Create an instance of your import and run it. By default it infers the model
to be imported from the classname, e.g.:

```ruby
import = UserImport.new
import.run # calls User.create!(row) for each row
```

The result is an instance of `Excelsieur::Result`:

```ruby
result = import.run
result.status
# => :succeeded
result.errors
# => { missing_column: [], model: [] }
result.report
# => #<struct Excelsieur::Report inserted=2, failed=0>
```

### Model validation

A summary of the `ActiveRecord` model validations is available after running
the importer. The `Error` objects indicates the failed excel row and the
corresponding errors.

```ruby
import = UserImport.new
import.run

import.errors[:model]
# => [#<struct Excelsieur::Error row=3, errors=["First name can't be blank"]>]
```

### Report

A summary of the successfully inserted and failed records is available after
running the importer.

```ruby
import = UserImport.new
import.run

import.report
# => #<struct Excelsieur::Report inserted=2, failed=1>

import.total
# => 3
```

### Transactions

When setting `transaction true` no record is inserted if any one of them has an error.

```ruby
class UserImporter < Excelsieur::Importer
  # declare the source file
  source "static/ftp/users.xlsx"

  # only insert all rows if none of them have an error
  transaction true

  # declare the mapping
  map "First Name", to: :firstname
  map "Last Name", to: :lastname
  map "E-Mail", to: :email
end
```

If a block is passed to `run` the block needs to raise an error in order to
roll back the transaction.

This means that the following will trigger a rollback if the model is not
valid:

```ruby
UserImport.new.run do |row|
  User.create!(row)
end
```

On the other hand, the following won't trigger a rollback if the model is
invalid:

```ruby
UserImport.new.run do |row|
  User.create(row)
end
```


### Extended API

You may want to pass an excel file per instance. You can also define your own
import behavior by passing a block to the `run` method:

```ruby
import = UserImport.new("users/all.xlsx")
import.run do |row|
  User.create!(row) # raise an exception if the data doesn't match your expectations
end
```

## Limitations
Be aware of a few limitations when considering this gem:
- only supports the first sheet in an excel file
- only supports `.xlsx` file format
- no export, just import

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/panter/excelsieur.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
