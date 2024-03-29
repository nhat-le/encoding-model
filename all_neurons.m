
aleft = cell(1, 180);
aright = cell(1, 180);
aone = cell(1, 180);
atwo = cell(1, 180);
athree = cell(1, 180);
afour = cell(1, 180);
areward = cell(1, 180);
acue = cell(1, 180);
apr = cell(1, 180);% all previously right
apw = cell(1, 180); % all previously wrong

for k = 1:180
    tfs = 15; %tfs = timeframes
    cue_cells = cell(tfs, 1); %within each cell is an added double of 173 values
    left = []; %only giving us the i (index) of trials that have left stimulus
    right = []; %same idea with right

    stim_onset_per_trial = [];

    correct = [];
    incorrect = [];
    prev_right = [];
    prev_wrong = [];

    one = [];
    two = [];
    three = [];
    four = [];

    for i = 1:length(neural_act_mat) %looping through all the trials
        
        %cue_cells{j} = neural_act_mat{i}(1:tfs, k);
        for j = 1:tfs
           cue_cells{j} = [cue_cells{j}, neural_act_mat{i}(j, k)] ; %adding the neural activity that corresponds to each cue onset
        end

        %finding out when the onset occurs
        if find(left_onsetCells{i})
            mid = find(left_onsetCells{i});
            left = [left, i];
        elseif find(right_onsetCells{i})
            mid = find(right_onsetCells{i});
            right = [right, i];
        end

        stim_onset_per_trial = [stim_onset_per_trial, mid];

        %tracking which trials are correct
        if any(rewardsCell{i}) %if a reward is presented
            correct = [correct, i];
            if ~(i + 1 == 174);
                prev_right = [prev_right, i + 1];
            end
        else %when there's no reward
            incorrect = [incorrect, i];
            if i~173;
                prev_wrong = [prev_wrong, i + 1];
            end
        end

         %finding out the level of difficulty
        val = difficultyGood(i);
        %organizing the various levels of difficulty
        if val == 0.3200
            one = [one, i];
        elseif val == 0.5600
            two = [two, i];
        elseif val == 0.6000
            three = [three, i];
        elseif val == 0.6400
            four = [four, i];
        end
    end

    %% difficulty levels

    one_array = loop_across(neural_act_mat, one, stim_onset_per_trial, k);
    two_array = loop_across(neural_act_mat, two, stim_onset_per_trial, k);
    three_array = loop_across(neural_act_mat, three, stim_onset_per_trial, k);
    four_array = loop_across(neural_act_mat, four, stim_onset_per_trial, k);

    %% worrying about previously correct (prev_right + prev_wrong)
    %timeframe is going to be the beginning
    beginning_per_trial = (zeros(173, 1) + 6)'; % a 173 x 1 matrix of all 6 values (to work with our looping across function)
    prev_right_array = loop_across(neural_act_mat, prev_right, beginning_per_trial, k);
    prev_wrong_array = loop_across(neural_act_mat, prev_wrong, beginning_per_trial, k);
    %%
    reward = correct; %trial # that were correct and thus had a reward

    %find reward_onset_per_trial through looping through reward D:
    reward_onset_per_trial = [];
    reward_onset_cells = cell(173, 1);
    
    for i = 1:length(reward)
        tn = reward(i); % tn = trial number
        reward_onset_cells{tn} = find(rewardsCell{tn});
    end
    
    for i = 1:length(reward_onset_cells)
        if length(reward_onset_cells{i}) == 0 ; %this will be true if it's empty
            reward_onset_cells{i} = 0;
        end
    end
    
    reward_onset_per_trial = cell2mat(reward_onset_cells);
    reward_array = loop_across(neural_act_mat, reward, reward_onset_per_trial, k);

    %% organizing choice

    correct_array = loop_across(neural_act_mat, correct, stim_onset_per_trial, k);
    incorrect_array = loop_across(neural_act_mat, incorrect, stim_onset_per_trial, k);
    cue_array = cell2mat(cue_cells);

    % calculating the mean - matter of doing mean(cue_array, 2)
    % and variances var(cue_array, 2)
     %% for left and right stimulus

    left_cells = cell(tfs, 1);
    right_cells = cell(tfs, 1);

    for i = 1:length(left)
        mid = find(left_onsetCells{left(i)});
        start = mid - 6;
        for j = 1:tfs
            left_cells{j} = [left_cells{j}, neural_act_mat{left(i)}(start + j, k)];
        end
    end

    for i = 1:length(right)
        mid = find(right_onsetCells{right(i)});
        start = mid - 6;
        for j = 1:tfs
            right_cells{j} = [right_cells{j}, neural_act_mat{right(i)}(start + j, k)];
        end
    end

    left_array = cell2mat(left_cells);
    right_array = cell2mat(right_cells);
    
%     figure;
%     plot(left_array, 'b');
%     hold on;
%     plot(mean(left_array, 2), 'r');
    
    aleft{k} = mean(left_array, 2);
    aright{k} = mean(right_array, 2);
    aone{k} = mean(one_array, 2);
    atwo{k} = mean(two_array, 2);
    athree{k} = mean(three_array, 2);
    afour{k} = mean(four_array, 2);
    areward{k} = mean(reward_array, 2);
    acue{k} = mean(cue_array, 2);
    apr{k} = mean(prev_right_array, 2);
    apw{k} = mean(prev_wrong_array, 2);
end

all_left = cell2mat(aleft);
all_right = cell2mat(aright);
all_one = cell2mat(aone);
all_two = cell2mat(atwo);
all_three = cell2mat(athree);
all_four = cell2mat(afour);
all_reward = cell2mat(areward);
all_cue = cell2mat(acue);
all_pr = cell2mat(apr);
all_pw = cell2mat(apw);

%we can now apply plot() or imagesc()

%% going through and finding peak information
[lp, lp_x, lp_y]  = find_peaks(all_left); 
%lp = left peaks (cell of cells // we're looking at per neuron)
%lp_x = array of all x values
%lp_y = array of all corresponding y values
[rp, rp_x, rp_y] = find_peaks(all_right);
[op, op_x, op_y] = find_peaks(all_one);
[twp, twp_x, twp_y] = find_peaks(all_two);
[thp, thp_x, thp_y] = find_peaks(all_three);
[fp, fp_x, fp_y] = find_peaks(all_four);
[rp, rp_x, rp_y] = find_peaks(all_reward);
[cp, cp_x, cp_y] = find_peaks(all_cue);
[prp, prp_x, prp_y] = find_peaks(all_pr);
[pwp, pwp_x, pwp_y] = find_peaks(all_pw);
 % can use sum(op_x(:) = val) to calculate how many points are in each
 % timeframe

 plot(all_left)
 
 
 %% Save the relevant variables
 reward_onset_per_trial = reward_onset_per_trial';
 save('TB41_behavior_summary_090519.mat', 'prev_right', 'prev_wrong', 'left', 'right',...
     'correct', 'incorrect', 'stim_onset_per_trial', 'one', 'two', 'three', 'four',...
     'reward_onset_per_trial');
 
