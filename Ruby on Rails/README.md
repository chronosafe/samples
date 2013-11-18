# Ruby on Rails Code Samples

Included is sample code from my latest project [VIN Vault](http://www.vinvault.com), which is a work in progress.  It's written using Ruby 2.0.0 and Rails 4.0.  It uses a variety of gems and the `RSpec` test suite for testing.

The site is a subscription site that allows users to sign up for access to the VIN decoding API that I use for my iOS apps.  The site uses [Stripe](http://www.stripe.com) for payment and Devise and CanCan for authentication and authorization.

The documentation for the API is available in the `VINVault API Documentation.md` file.

### App directory
I've tried to include a variety of code from each of the categories of Rails files.  The site is divided into a front end presentation for signing up for the service as well as accessing the API.

The API is versioned, with a separate controller for each version but one common API.

The site supports two sets of data: modern data and classic vehicle data, stored in two sets of classes (e.g. `Vehicle` and `ClassicVehicle`.  There is a single `Decode` class that can represent both data sets using a polymorphic association.

The classic data is in a custom DSL that can be imported into the database and validated. I use the custom DSL instead of XML because of the relationships that need to be established.  The rake task `classic_import` handles the process of importing and validating the data.  See the DSL files in the `source` directory.

### Testing
I have almost 300 RSpec tests written to support the application.  I have included the entire test suite in the sample.

### Worker Tasks
I have code that supports the creation of batch jobs that can be uploaded and then processed in a separate thread.  The `worker_bee` class handles the processing of these files (which are uploaded to Amazon's S3) and then the results are emailed to the user.