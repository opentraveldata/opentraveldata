#!/usr/bin/env python
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
# Seth Vidal - skvidal@fedoraproject.org.
# (c) Duke University 2006
# (c) Red Hat, Inc 2012 - updated

# Source: http://skvidal.fedorapeople.org/misc/copy_if_changed.py

# copy_if_changed - copy file from a remote url to local destination. Return 0
# if file has changed, 1 if it hasn't and 2 if an error occurs

# usage is: copy_if_changed url /some/local/destination


# md5/sha1 checksum dest file
# download src to templocation
# if not same:
    # makes backup of dest
    # mv tempsrc onto dest
    # returns 0 if everything worked
# returns 1 if no change
# returns 2 if an error occurred


import os
import sys
import shutil
from urlgrabber import grabber
#import subprocess
import tempfile
import time
import types
import hashlib




def error(msg):
    print >> sys.stderr, msg

def retrievefile(url):
    """do the actual file retrieval to a temp dir, return tempdir+file"""
    tmpdir = tempfile.mkdtemp()
    fn = os.path.basename(url)
    tmpfn = '%s/%s' % (tmpdir, fn)
    # XXX Note - maybe make an option to use wget or curl directly here.?
    try:
        loc = grabber.urlgrab(url, filename=tmpfn)
    except grabber.URLGrabError, e:
        error('Error downloading %s: %s' % (url, e))
        return None

    return loc

def backuplocal(fn):
    """make a date-marked backup of the specified file, return True or False on success or failure"""
    # backups named basename-YYYY-MM-DD@HH:MM~
    ext = time.strftime("%Y-%m-%d@%H:%M~", time.localtime(time.time()))
    backupdest = '%s.%s' % (fn, ext)
    
    try:
        shutil.copy2(fn, backupdest)
    except shutil.Error, e:
        error('Error making backup of %s to %s: %s' % (fn, ext, e))
        return False
    return True

def finalmove(src, dest):
    # make the dir if need be
    # mv the file into place
    dirn = os.path.dirname(dest)
    if not os.path.exists(dirn):
        os.makedirs(dirn)

    try:
        shutil.move(src, dest)
    except shutil.Error, e:
        error('Error moving %s to %s: %s' % (src, dest, e))
        return False
    return True
    
def getChecksum(fn, CHUNK=2**16):
    """takes filename, hand back Checksum of it
       filename = /path/to/file
       CHUNK=65536 by default"""
    
    # chunking brazenly lifted from Ryan Tomayko
    if type(fn) is not types.StringType:
        fo = fn # assume it's a file-like-object
    else:
        fo = open(fn, 'r', CHUNK)

    thissum = hashlib.sha256()
    chunk = fo.read
    while chunk:
        chunk = fo.read(CHUNK)
        thissum.update(chunk)

    if type(fn) is types.StringType:
        fo.close()
        del fo

    return thissum.hexdigest()



def main(src, dest):
    # make sure the dest is absolute so we aren't making booboos.
    dest = os.path.abspath(dest)
    destlock = '%s.copylocked' % dest
    if os.path.exists(destlock):
        error('%s lock file exists, not copying' % destlock)
        sys.exit(2)

    # get remote file
    locpath = retrievefile(src)
    if not locpath:
        error('File %s could not be downloaded and/or saved' % src)
        sys.exit(2)
    
    # if the file size of locpath and dest don't match then there is
    # no point in checksumming
    if os.path.exists(dest) and os.stat(locpath).st_size == os.stat(dest).st_size:
        # checksum file we just downloaded
        rem_csum = '0'
        if os.path.exists(locpath):
            rem_csum = getChecksum(locpath)

        # checksum local file
        loc_csum = '0'
        if os.path.exists(dest):
            loc_csum = getChecksum(dest)
        
        
        # now we're in the homestretch
        # they're the same - we're done.
        if loc_csum == rem_csum: 
            sys.exit(1)

    if os.path.exists(dest):
        if not backuplocal(dest):
            error('Could not make backup file for %s' % dest)
            sys.exit(2)
    
    if not finalmove(locpath, dest):
        error('Could not move file %s into final place %s' % (src, dest))
        sys.exit(2)
    
    # we succeeded!
    sys.exit(0)



if __name__ == '__main__':
    if len(sys.argv) < 3:
        error("Usage: copy_if_changed: src dest")
        sys.exit(3)
    
    src = sys.argv[1]
    dest = sys.argv[2]

    
    main(src, dest)
