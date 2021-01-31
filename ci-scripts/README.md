OpenTravelData (OPTD) - Release of Data Files
=============================================

# Overview
The [original of that documentation file](https://github.com/opentraveldata/opentraveldata/blob/master/ci-scripts/README.md)
is maintained on the
[OpenTravelData (OPTD) project](https://github.com/opentraveldata/opentraveldata),
within the [`ci-scripts` directory](https://github.com/opentraveldata/opentraveldata/blob/master/ci-scripts).

OPTD produces at least two kinds of (mainly CSV) data files:

* OPTD CSV data files, typically curated, maintained and hosted on
  [GitHub in the `opentraveldata` folder](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/),
  such as [`opentraveldata/optd_por_public_all.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public_all.csv)
  and [`opentraveldata/optd_airlines.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_airlines.csv)
* Results from the [Quality Assurance (QA)](https://github.com/opentraveldata/quality-assurance)
  [checking/monitoring processes](https://github.com/opentraveldata/quality-assurance/tree/master/checkers)

The deployment/release itself is managed through [Travis CI](https://www.travis-ci.org/opentraveldata/opentraveldata),
specified in the [`.travis.yml` YAML file](https://github.com/opentraveldata/opentraveldata/blob/master/.travis.yml).

## References
* [OpenTravelData (OPTD) organization on GitHub](https://github.com/opentraveldata)
  + [OPTD Data Management](https://github.com/opentraveldata/opentraveldata)
  + [OPTD Quality Assurance (QA)](https://github.com/opentraveldata/quality-assurance)
* Python wrappers/tools
  + [OPTD Python wrapper](https://pypi.org/project/opentraveldata/)
  + [OpenTREP Python wrapper](https://pypi.org/project/OpenTrepWrapper/)
  + [Neobase](https://github.com/alexprengere/neobase) (all-in-one, light, modern version of GeoBases)
  + [GeoBases](http://opentraveldata.github.com/geobases)
* Documentation format online helper tool
  + [Dillinger](https://dillinger.io)

## Content
* [`cicd/`](cicd/)
* [`qa/`](qa/)
* [`por/`](por/)

## Upgrade Python dependencies

* If not already done so, clone the OPTD and
  OPTD Quality Assurance (QA) reporitories:
```bash
$ mkdir -p ~/dev/geo && \
  git clone https://github.com/opentraveldata/quality-assurance.git ~/dev/geo/opentraveldata-qa &&
  git clone https://github.com/opentraveldata/opentraveldata.git ~/dev/geo/opentraveldata
```

* When using PyEnv installed in the home directory, update it:
```bash
$ pushd ~/.pyenv && git pull && popd
```

* Re-initialize the Python virtual environment, potentially upgrading
  to the latest Python version (check `.python-version` and `Pipfile`):
```bash
$ cd ~/dev/geo/opentraveldata-qa
$ pyenv local 3.9.1 # for instance (as of January 2021)
$ pipenv --rm ; rm -f Pipfile.lock ; pipenv install
```

* Re-generate the `requirements.txt` Python dependency file:
```bash
$ pipenv lock -r > requirements.txt
```

* If all is successful, add to Git and commit:
```bash
$ git diff
$ git add .python-version Pipfile Pipfile.lock requirements.txt
$ git commit -m "[Python] Upgraded the dependencies"
```

* Copy the Python dependency file into the OPTD project,
  in the `ci-scripts/` directory:
```bash
$ cp requirements.txt ~/dev/geo/opentraveldata/ci-scripts/
$ pushd ~/dev/geo/opentraveldata && \
  git add requirements.txt && \
  git commit -m "[Python] Upgraded the dependencies" && \
  popd
```


