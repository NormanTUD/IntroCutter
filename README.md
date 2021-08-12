# Idea

This script gets as a parameter a folder with mp4-files. It will create 2 frames from every second of the first 2 minutes and then group them
by a perceptual-hashing-algorithm, order the hashes by number of occurences and then get the highest hash-number frame, from which the timing
is calculated. This is based on the idea that intros are almost the same over a season of a series and always end with a similiar frame.

# Dependencies

```console
sudo cpan -i Digest::MD5::File
sudo pip3 install imagehash
```

# How-to

```console
perl cutter.pl --debug --dir=/dir/to/your/series/The-Simpsons/5/
```

This will create a `.intro_endtime` in that folder, in which all the episodes are listed and when the intro ends.

Together with [SerienWatcher](https://github.com/NormanTUD/SerienWatcher) it can be used to automatically skip intros.
