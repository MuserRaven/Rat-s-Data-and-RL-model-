
% 'query' is a string in the SQL syntax and it must have the form 'select * from sess_ended where . . . '
% example: query = 'SELECT * FROM sess_ended WHERE ratname = "C006"'
function S = getBanditData(query)
%S = getBanditData('select * from sess_ended where ratname = "D003" and end_time > "2021-02-01"')

conn = ConnectDB;
% conn.Message %checks connection, [] if working
rawinfo = select(conn,query);
info = sortrows(rawinfo, 'end_time'); % sorts info table so that sessions are in chronological order.

data = info.json;
sessions = size(data);

ctr = 0;
%Create concatenated struct of every session from rat
for j = 1:sessions
    if ~strcmp(data{j}, '0.0')
        
        chara = char(data{j,1}); %create character array for jsondecode
        SessionData = jsondecode(chara);
        
        if SessionData.nTrials > 200
            ctr = ctr+1;
            
            TS = arrayfun(@(x)x.TrialSettings, SessionData, 'UniformOutput', 0);
            RE = arrayfun(@(x)x.RawEvents.Trial, SessionData, 'UniformOutput', 0);
            nTrials = SessionData.nTrials;
            % side = SessionData.TrialTypes;
            %   RewardedSide = cell(size(side));
            %   RewardedSide(find(side==1)) = {'L'};
            %   RewardedSide(find(side==2)) = {'R'};
            
            if nTrials < 10
                S.pd{ctr} = NaN;
            else
                
                for n = 1:nTrials
                    if isempty(TS{1,1}(n).GUI)
                        TS{1,1}(n).GUI.Stage = NaN;
                        TS{1,1}(n).GUI.ThisBlock = NaN;
                        TS{1,1}(n).GUI.BlockLength = NaN;
                        TS{1,1}(n).GUI.Pright = NaN;
                        TS{1,1}(n).GUI.Pleft = NaN;
                        TS{1,1}(n).GUI.SideLights = NaN;
                        TS{1,1}(n).GUI.CenterLight = NaN;
                        TS{1,1}(n).GUI.ITI = NaN;
                        TS{1,1}(n).GUI.NIC = NaN;
                        TS{1,1}(n).GUI.tcounter = NaN;
                        TS{1,1}(n).GUI.lhit = NaN;
                        TS{1,1}(n).GUI.rhit = NaN;
                        TS{1,1}(n).GUI.RewardAmount = NaN;
                    end
                end
                
                S.pd{ctr}.NIC = arrayfun(@(x)x.GUI.NIC, TS{1,1});
                S.pd{ctr}.Stage = arrayfun(@(x)x.GUI.Stage, TS{1,1});
                S.pd{ctr}.ThisBlock = arrayfun(@(x)x.GUI.ThisBlock, TS{1,1});
                S.pd{ctr}.BlockLength = arrayfun(@(x)x.GUI.BlockLength, TS{1,1});
                S.pd{ctr}.Pright = arrayfun(@(x)x.GUI.Pright, TS{1,1});
                S.pd{ctr}.Pleft = arrayfun(@(x)x.GUI.Pleft, TS{1,1});
                S.pd{ctr}.SideLights = arrayfun(@(x)x.GUI.SideLights, TS{1,1});
                S.pd{ctr}.CenterLight = arrayfun(@(x)x.GUI.CenterLight, TS{1,1});
                S.pd{ctr}.ITI = arrayfun(@(x)x.GUI.ITI, TS{1,1});
                S.pd{ctr}.tcounter = arrayfun(@(x)x.GUI.tcounter, TS{1,1});
                if isfield(TS{1,1}(n).GUI, 'lhit')
                    S.pd{ctr}.lhit = arrayfun(@(x)x.GUI.lhit, TS{1,1});
                    S.pd{ctr}.rhit = arrayfun(@(x)x.GUI.rhit, TS{1,1});
                else
                    S.pd{ctr}.lhit = nan(length(S.pd{ctr}.ITI),1);
                    S.pd{ctr}.rhit = nan(length(S.pd{ctr}.ITI),1);
                end
                S.pd{ctr}.RewardAmount = arrayfun(@(x)x.GUI.RewardAmount, TS{1,1});
                S.pd{ctr}.SessionDate = SessionData.Info.SessionDate;
                S.pd{ctr}.RatName = char(info.ratname(j));
                S.pd{ctr}.SessId = char(info.sessid(j));
                S.pd{ctr}.Protocol = char(info.protocol(j));
                % S.pd{j}.RewardedSide = RewardedSide';
                %fields = fieldnames(RE{1,1}(1));
                
                
                
                for n = 1:nTrials
                    fields = fieldnames(SessionData.RawEvents.Trial(n).States);
                    for m = 1:size(fields)
                        state = char(fields(m));
                        S.peh{ctr}(n).States.(state) = SessionData.RawEvents.Trial(n).States.(state);
                    end
                    events = fieldnames(SessionData.RawEvents.Trial(n).Events);
                    for m = 1:size(events)
                        event = char(events(m));
                        if strcmp(events(m), 'Port1In')
                            S.peh{ctr}(n).Events.LeftIn = SessionData.RawEvents.Trial(n).Events.(event);
                        elseif strcmp(events(m), 'Port2In')
                            S.peh{ctr}(n).Events.CenterIn = SessionData.RawEvents.Trial(n).Events.(event);
                        elseif strcmp(events(m), 'Port3In')
                            S.peh{ctr}(n).Events.RightIn = SessionData.RawEvents.Trial(n).Events.(event);
                        elseif strcmp(events(m), 'Port1Out')
                            S.peh{ctr}(n).Events.LeftOut = SessionData.RawEvents.Trial(n).Events.(event);
                        elseif strcmp(events(m), 'Port2Out')
                            S.peh{ctr}(n).Events.CenterOut = SessionData.RawEvents.Trial(n).Events.(event);
                        elseif strcmp(events(m), 'Port3Out')
                            S.peh{ctr}(n).Events.RightOut = SessionData.RawEvents.Trial(n).Events.(event);
                        else
                            S.peh{ctr}(n).Events.(event) = SessionData.RawEvents.Trial(n).Events.(event);
                        end
                    end
                end
                
                
                if isfield(RE{1,1}(1).States, 'Reward')
                    S.pd{ctr}.hits = arrayfun(@(x) min(~isnan(x.States.Reward)),RE{1,1});
                end
                if isfield(RE{1,1}(1).States, 'Reward') && isfield(RE{1,1}(1).States, 'AnnounceReward')
                    S.pd{ctr}.ReactionTime =(arrayfun(@(x)x.States.Reward(1), RE{1,1})- (arrayfun(@(x)x.States.AnnounceReward(1), RE{1,1})));
                end
                if isfield(RE{1,1}(1).States,'PunishViolation')
                    S.pd{ctr}.vios = arrayfun(@(x) min(~isnan(x.States.PunishViolation)),RE{1,1});
                end
                
                if isfield(RE{1,1}(1).States,'RightChoice')
                    S.pd{ctr}.wr = arrayfun(@(x) min(~isnan(x.States.RightChoice)), RE{1,1});
                end
                
                if isfield(RE{1,1}(1).States,'LeftChoice')
                    S.pd{ctr}.wl = arrayfun(@(x) min(~isnan(x.States.LeftChoice)), RE{1,1});
                end
                
                if isfield(RE{1,1}(1).States, 'WaitForPoke')
                    S.pd{ctr}.WaitForPoke = (arrayfun(@(x)x.States.WaitForPoke(2), RE{1,1}) - (arrayfun(@(x)x.States.WaitForPoke(1),RE{1,1})));
                end
                
          
            end
        end
    end
end


