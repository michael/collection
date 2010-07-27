Collection API
================================================================================

A Ruby API for the [Unveil.js](http://github.com/michael/unveil/) collection
interface. Useful for exporting all kinds of data in a uniform Collection format.


Usage
--------------------------------------------------------------------------------

    c = Collection.new
    c.property(:customer, {:name => "Customer", :type => String, :unique => true })
    c.property(:product,  {:name => "Product", :type => String, :unique => true })
    c.property(:quantity, {:name => "Salesman", :type => Numeric, :unique => true })
    c.property(:price,    {:name => "Price", :type => Numeric, :unique => true })
    
    c.add("IO47181", {
      :customer => "John Smith",
      :product  => "XT52",
      :quantity => 21,
      :price    => 231.5
    })
    
    c.to_json => A JSON string that conforms to an Unveil.js Collection
    c.to_csv => Plain old CSV representation, if your clients can't get around Excel :/


Note on Patches/Pull Requests
--------------------------------------------------------------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
--------------------------------------------------------------------------------

Copyright (c) 2010 Michael Aufreiter. See LICENSE for details.
