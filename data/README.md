# Data

This folder is for re-runnable data scripts. Re-runnable data scripts are most common for List of Value (LOV) / lookup tables. This allows developers to easily manage the LOV data rather than end users. It also prevents having to manually write updates each time one is required. It is recommended to name each file `data_table_name.sql`. When opening files in VSCode using the [Command Palette](https://code.visualstudio.com/docs/getstarted/tips-and-tricks#_quick-open) you can quickly find `data` scripts when using the Command Palette's [Quick Open](https://code.visualstudio.com/docs/getstarted/tips-and-tricks#_quick-open) feature. *Note: other modern text editors have similar functionality*

*Note: If you have one-off data updates it should be part of a [release](../release/)*

A [template](../templates/template_data.sql) is provided for data scripts. It uses a `merge` concept that joins LOV values on codes. By joining on codes rather than IDs it removes any differences in sequences that may occur across environments.

