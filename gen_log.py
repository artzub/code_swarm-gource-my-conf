#!/usr/bin/env python
from optparse import OptionParser
from xml.sax.saxutils import XMLGenerator
import sys
import subprocess


def cmp(a, b):
    return (a > b) - (a < b)


class Event(object):
    """ Event to hold all of the separate events as we parse them from the logs. """
    def __init__(self, filename, date, author, action):
        self.filename = filename
        self.date = date
        self.author = author
        self.action = action

    def properties(self):
        """returns a dict of properties and their names for XML serialization"""
        return {
            "date": self.date,
            "filename": self.filename,
            "author": self.author,
            "action": self.action,
        }

    def __lt__(self, other):
        return cmp(self.date, other.date)


def parse_args(argv):
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)

    parser.add_option(
        '-g', '--gource-log',
        dest='gource',
        action='store_true',
        help='convert to gource',
        default=True
    )

    parser.add_option(
        '-l', '--logstalgia-log',
        dest='logstalgia',
        action='store_true',
        help='convert to logstalgia',
    )

    parser.add_option(
        '-c', '--code_swarm-log',
        dest='code_swarm',
        action='store_true',
        help='convert to code_swarm',
    )

    parser.add_option(
        '-p', '--prefix',
        dest='prefix',
        help='prefix for output filename',
        default='actions'
    )

    parser.add_option(
        '-a', '--author',
        dest='author',
        action='store_true',
        help='extract author name',
    )

    parser.add_option(
        '-e', '--email',
        dest='email',
        action='store_true',
        help='extract committer email'
    )

    parser.add_option(
        '-n', '--name',
        dest='name',
        action='store_true',
        help='extract committer name'
    )

    (options, args) = parser.parse_args(argv)

    return options, args


command = 'git log --name-status --pretty=format:user:{}%n%ct000 --no-renames --encoding=UTF-8 --reverse'


def main(argv):
    options, args = parse_args(argv)

    author = '%aN'
    if options.email:
        author = '%ce'
    elif options.name:
        author = '%cn'

    git_log = subprocess.run(command.format(author), capture_output=True, check=True)

    if git_log.returncode > 0:
        print(git_log.stderr, file=sys.stderr)
        sys.exit(1)

    events = extract(git_log.stdout.decode('utf-8'))

    output_g = None
    output_l = None
    output_c = None

    if options.gource:
        output_g = open('{}_gource.log'.format(options.prefix), 'w')
    if options.logstalgia:
        output_l = open('{}_logstalgia.log'.format(options.prefix), 'w')
    if options.code_swarm:
        output_c = open('{}_codeswarm.xml'.format(options.prefix), 'w')

    convert(events, output_g, output_l, output_c)


def extract(source):
    lines = source.split('\n')
    lines.reverse()
    date, author = '', ''
    while len(lines) > 0:
        line = lines.pop()
        if line.startswith('user:'):
            author = line.split(':')
            author = author[1].replace("\n", "")

            date = lines.pop()
            continue

        if len(line) < 1:
            continue

        action, path = line.split('\t')
        yield Event(path, date, author, action)
    pass


str_format = '{}|{}|{}|{}'
codes = {
    'A': 'Added|128|1|5AE069',
    'M': 'Modified|128|1|FEC466',
    'D': 'Deleted|128|0|FF6C66',
}


def convert(events, gource, logstalgia, codeswarm):
    generator = None
    if codeswarm is not None:
        generator = XMLGenerator(codeswarm, "utf-8", True)
        generator.startDocument()
        generator.startElement('file_events', {})

    for event in events:
        if generator is not None:
            generator.startElement("event", event.properties())
            generator.endElement("event")

        if gource is not None:
            print(str_format.format(event.date[:-3], event.author, event.action, event.filename), file=gource)

        if logstalgia is not None:
            print(str_format.format(event.date[:-3], event.author, event.filename, codes[event.action]), file=logstalgia)

    if codeswarm:
        generator.endElement('file_events')
        generator.endDocument()

    pass


# Main entry point.
if __name__ == "__main__":
    main(sys.argv)
