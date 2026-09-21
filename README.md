# Sonic Lineup for Apple Silicon

An unofficial native build for Apple Silicon of Sonic Lineup, the application for aligning and comparing recordings of one work developed at the Centre for Digital Music, Queen Mary University of London. The fork touches only the build and the bundle; the original notes follow unaltered.

- **Download.** Each [release](https://github.com/yrammos/sonic-lineup-arm64/releases) carries the zipped application; unzip it and move `Sonic Lineup.app` to Applications. Its notes state the minimum macOS version.
- **First launch.** Being ad hoc signed rather than notarized, the app is blocked by macOS at first launch. Allow it under System Settings › Privacy & Security › Open Anyway, or clear the quarantine attribute:

  ```sh
  xattr -dr com.apple.quarantine "/Applications/Sonic Lineup.app"
  ```

- **Building from source.** See [BUILD-arm64.md](BUILD-arm64.md).
- **License.** GPL, as upstream (`COPYING`). Each release is tagged at the commit from which it was built. Upstream repository: [sonic-visualiser/sonic-lineup](https://github.com/sonic-visualiser/sonic-lineup).

---


Sonic Lineup
============

#### An application for comparative visualisation and alignment of related audio recordings

Sonic Lineup is an application for quick read-only comparative
visualisation of multiple audio files whose contents consist of
different performances of the same work or recordings of the same
material.

For more information, please see http://www.sonicvisualiser.org/sonic-lineup/.


Credits
-------

Sonic Lineup was developed at the Centre for Digital Music,
Queen Mary, University of London.

  http://c4dm.eecs.qmul.ac.uk/

Sonic Lineup was written by Chris Cannam, copyright 2005-2007 Chris
Cannam and copyright 2006-2019 Queen Mary, University of London,
except where indicated in the individual source files.

Sonic Lineup incorporates a number of audio analysis plugins:

* MATCH Audio Alignment Plugin, by Simon Dixon and Chris Cannam
* NNLS Chroma and Chordino, by Matthias Mauch
* pYIN Pitch Estimator, by Matthias Mauch
* QM Key Estimator, by Katy Noland and Christian Landone

Distributed under the GNU General Public License. See the file COPYING
for details.


Automated build reports
-----------------------

 * Linux and macOS CI build: [![Build Status](https://travis-ci.org/sonic-visualiser/sonic-lineup.svg?branch=default)](https://travis-ci.org/sonic-visualiser/sonic-lineup)
 * Windows CI build: [![Build status](https://ci.appveyor.com/api/projects/status/4r68mde0dlqk4sa5?svg=true)](https://ci.appveyor.com/project/cannam/sonic-lineup)
