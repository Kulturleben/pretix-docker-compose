#!/usr/bin/env python3
import os
import sys
from configparser import ConfigParser

def substitute_config_vars(config_path):
    """Substitute environment variables in the Pretix config file."""
    config = ConfigParser()
    
    # Read the original configuration
    with open(config_path, 'r') as f:
        config.read_string(f.read())
    
    # Go through each section and option to do substitution
    for section in config.sections():
        for option in config.options(section):
            value = config.get(section, option)
            # Replace %(VAR_NAME)s patterns with environment variable values
            substituted = value
            for key, val in os.environ.items():
                # Check for %(KEY)s pattern and replace with environment value
                pattern = f"%({key})s"
                if pattern in substituted:
                    substituted = substituted.replace(pattern, val)
            config.set(section, option, substituted)
    
    # Write the new configuration back to the file
    with open(config_path, 'w') as f:
        config.write(f)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 substitute_config.py <config_file_path>")
        sys.exit(1)
    
    config_path = sys.argv[1]
    substitute_config_vars(config_path)
    print(f"Configuration file {config_path} updated with environment variables.")