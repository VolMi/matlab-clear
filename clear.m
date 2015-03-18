function clear( varargin )
%intercept amok calls to clear() in interactive mode
%
% So you do something in an interactive Unix Shell and type 'clear'
% to get rid of some annoying ouput.
% Then you switch to MATLAB, do the same and lose all your current work.
% Syntax madness... o_O
%
% It feels fundamentally wrong that MATLAB's clear() assumes
% that 'no input' == 'everything'. This function is the workaround, effective only
% for interactive calls. I would like to apply this to script calls, too, but
% this breaks a lot of matlab's own code.
%
% This function intercepts all calls of clear() (hence the name...) and
% decides what to do based on the given arguments and whether it was called
% from the command window or not.
%
% in pseudo code:
%
% IF  < NO ARGUMENT, I.E. CLEAR EVERYTHING >
%
%       IF  < IS INTERACTIVE >
%
%           < ASK USER EXPLICITLY IF THEY WANT TO ERASE EVERYTHING >
%
%           IF  < NO, THEY DON'T >   % <-- safety net
%               RETURN
%           END
%       END
% END
%
%  <DEFAULT CLEAR CODE>
%
%
% Note:
%   'clear all' or 'clear variables' will still clear everything immediately, because
%   it was specifically asked to do so!
%
% This relies on undocumented MATLAB/JAVA code to get the last command from
% the history. If the command fails (maybe very old or very new MATLAB),
% this is caught by try/catch and clear behaves completely like the
% builtin function. So, don't rely on it, just have it as a safety net!
%
% Usage
% =====
%       Save this m-file anywhere in your matlab path such that it has
%       precedence over the builtin implementation. That is, make sure
%       that
%           >> which clear
%       returns the path to this file.
%
% SEE ALSO
% clear

% blame: Michael Völker

% The actual clear() has to be called as builtin( 'clear', 'var1', 'var2', ...).
% And this has to done in the calling workspace and with whatever size
% of varargin.
% So this function ends up a bit messy but it's about the least-messy way
% I could figure.


if isempty( varargin )

    % --- amok mode -------------------------------------------------------

    isInterActive = false;

    try
        % Evaluate the last command. Believe that this command led to us
        % being here... Is this assumption always valid?
        %
        % https://stackoverflow.com/questions/5053692/how-do-i-search-through-matlab-command-history
        hist = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
        if ~isempty( hist )
            last = char(hist(end));

            if    ~isempty( regexp( last, '^ *clear *;*$', 'once' )      ) ... % >> clear / clear; / clear    ;
               || ~isempty( regexp( last, '^ *clear\( *\) *;*$', 'once' )) ... % >> clear() / clear(    ); / clear( )  ;

                isInterActive = true;
            end
        end
    catch exception
%         warning( 'clear:CaughtExc',     ...
%                  'Got an error when trying to read com.mathworks.mlservices.[...]. Message was:\n%s',   ...
%                   exception.message )
    end

    % safety net
    if isInterActive
        wish = input( [ 'You just called ''clear'' with not argument.\n'                ...
                        'Maybe you meant ''clc'', to empty the command prompt.\n'       ...
                        'Do you really want to clear *ALL* your workspace variables?\n' ...
                        'Type ''YeS'' without the quotes:\n' ], 's');

        if ~strcmp( wish, 'YeS' )
            fprintf( '''YeS'' =|= ''%s'', so good luck, we saved your workspace.\n', wish )
            return
        end
    end
end


% --- explicit mode -------------------------------------------------------


% Execute builtin( 'clear', varargin{:} ) in the calling workspace.
% This is hard, because we cannot pass 'varargin{:}' directly.
% But we can first copy varargin to a tmp variable in the calling workspace and
% execute builtin( 'clear', CopyOfVarargin{:} ) there.
CopyOfVarargin = 'IknowThisVarCanBeOverWrittenAnyTime';
assignin( 'caller', CopyOfVarargin, varargin );
try
    evalin( 'caller', [ 'builtin( ''clear'', ' CopyOfVarargin '{:} )' ]);
catch exception

    % clear the dummy first
    evalin('caller', 'builtin(''clear'', ''IknowThisVarCanBeOverWrittenAnyTime'')' )
    rethrow( exception )
end

% clear the dummy
evalin('caller', 'builtin(''clear'', ''IknowThisVarCanBeOverWrittenAnyTime'')' )

end % of clear()
