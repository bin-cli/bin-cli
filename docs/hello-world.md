# Hello, World!

This is a very simple script, as listed above:

```bash
#!/bin/sh
echo 'Hello, World!'
```

It will run using the default system shell - in Ubuntu, that is Dash rather than Bash, which is a little faster but doesn't have all the same features.

If you want to use Bash instead, you could use `#!/bin/bash`, but it is better to use this variant, which should work even if Bash is installed in another location (e.g. by [Homebrew](https://brew.sh/)):

```bash
#!/usr/bin/env bash
echo 'Hello, World!'
```

For non-trivial scripts, I recommend adding `set -euo pipefail`, or equivalent, [for safety](https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/).

```bash
#!/usr/bin/env bash
set -euo pipefail

# ...
```

For scripts written in other programming languages, just change the executable name as appropriate:

```python
#!/usr/bin/env python3
print('Hello, World!')
```

```ruby
#!/usr/bin/env ruby
puts 'Hello, World!'
```

```perl
#!/usr/bin/env perl
print "Hello, World!\n";
```

```php
#!/usr/bin/env php
<?php
echo "Hello, World!\n";
```
