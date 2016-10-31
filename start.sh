#!/bin/bash

while true;

do

	java -cp bin:lib/* stream.PrintFilterStream $* "";

done;

