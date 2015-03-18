# clear
A safety net for MATLAB's clear command

So you do something in an interactive Unix Shell and type 'clear'
to get rid of some annoying ouput.
Then you switch to MATLAB, do the same and lose all your current work.
Syntax madness... o_O

It feels fundamentally wrong that MATLAB's clear() assumes
that 'no input' == 'everything'. This function is the workaround, effective only
for interactive calls. I would like to apply this to script calls, too, but
this breaks a lot of matlab's own code.

This function intercepts all calls of clear() (hence the name...) and
decides what to do based on the given arguments and whether it was called
from the command window or not.

in pseudo code:

    IF  < NO ARGUMENT, I.E. CLEAR EVERYTHING >

          IF  < IS INTERACTIVE >

              < ASK USER EXPLICITLY IF THEY WANT TO ERASE EVERYTHING >

              IF  < NO, THEY DON'T >   % <-- safety net
                  RETURN
              END
          END
    END

     <DEFAULT CLEAR CODE>


Note:
  'clear all' or 'clear variables' will still clear everything immediately, because
  it was specifically asked to do so!

This relies on undocumented MATLAB/JAVA code to get the last command from
the history. If the command fails (maybe very old or very new MATLAB),
this is caught by try/catch and clear behaves completely like the
builtin function. So, don't rely on it, just have it as a safety net!

Usage
-----
      Save this m-file anywhere in your matlab path such that it has
      precedence over the builtin implementation. That is, make sure
      that
          >> which clear
      returns the path to this file.

This is [Filexchange #50092](http://www.mathworks.com/matlabcentral/fileexchange/50092)
