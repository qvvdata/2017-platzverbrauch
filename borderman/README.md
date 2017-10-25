# BorderMan 

BorderMan is a collection of functions that allows municipality-level to be compared across multiple waves of mergers and re-numerations of municipalities.

The `borderman` function receives a dataframe with the following properties:
- `name` - Municipality name (will be ignored) - character
- `gkz` - Municipality code at the time the data was collected - **character**
- one or more other columns containing absolute numbers, which will be summed up if multiple gkz got merged across time - numeric

The return value will be a dataframe with `gkz_neu` and the same value columns as above.


The `remove_teilungen` function receives a dataframe and returns the same dataframe without municipalities which have been split during the known timeframe.

Both functions access a public Google Spreadsheet maintained by dst-data, containing municipality merge/split data for 2007-2015.
