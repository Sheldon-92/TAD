#!/bin/sh

to_upper() {
  LC_ALL=C tr '[:lower:]' '[:upper:]'
}

to_upper
