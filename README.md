# Preside DB Field Compression extension

The DB Field compression extension for Preside aims to deliver an extremely straight forward way of compressing data for storage in databases. Data will automatically be stored in a compressed format and automatically decompressed when read back from the database. Just add `compress=true` to your property definitions in your Preside objects.


## Install with:

```bash
box install preside-ext-field-compression
```

## Configuration and usage

All that is required is to add the `compress=true` attribute to any object properties whose data you wish to be compressed. For example:

```cfc
property name="email_content" type="string" dbtype="longtext" compress=true;
```

## Notes and warnings

This software extension should be considered ALPHA and has not yet been used in a production environment. Please always thoroughly test before use.

### Consider other approaches 

Another, arguably preferable, approach here would be to write compressed content to a separate file store, and store only the path to the file. This will prevent the size of your database increasing, but potentially give you increased code and infrastructure complexity.

Also, if using InnoDB, entire row compression can be enabled. See the MySQL documentation for details.

### We only compress into a base64 string

If we were to store the content in `binary` format, without base64 encoding, we would be able to get better performing compression. We have currently chosen to to this to decrease implementation complexity. i.e. you can take an existing dataset and start compressing new data, without the need to alter your data model.

One potential feature to improve this would be to detect the database field type and only convert to base64 when it is a non `blob` field. Pull requests welcome!

## Contributing

Contribution in all forms is very welcome. Use Github to create pull requests for tests, logic, features and documentation. Or, get in touch over at Preside's slack team and we'll be happy to help and chat: [https://presidecms-slack.herokuapp.com/](https://presidecms-slack.herokuapp.com/).
