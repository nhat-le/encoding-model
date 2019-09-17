import numpy as np
import scipy.io
import matplotlib.pyplot as plt
import pandas as pd
import utils
import mat4py
import neuron_group_utils
import neuron_utils


animal = 'TB146'

if animal == 'TB146':
    samp_rate = 12.2 #Hz, 12.2 for TB146 and 5 Hz for TB41
    date = '20190807'
    window = [-10, 32]
    summary_fname = animal + '_' + date + '_behavior_summary.mat'
    encoding_fname = animal + '_' + date + '_encoding_structs.mat'
    epoch_fname = animal + '_' + date + '_epochs.mat'
elif animal == 'TB41':
    samp_rate = 5
    window = [-5, 16]
    summary_fname = 'TB41_behavior_summary.mat'
    encoding_fname = 'TB41_encoding_structs.mat'
    epoch_fname = 'TB41_epochs.mat'


# Make an experiment object to capture the experiment
exp_dict = dict(rate=samp_rate, window=window)
exp = neuron_utils.Experiment(exp_dict)

neuron_group = utils.make_neuron_group(encoding_fname, epoch_fname, exp)

# Extract structures from the raw data
raw_behavior_summary = mat4py.loadmat(summary_fname)
one, two, three, four, correct, incorrect, left, right, prev_corr, prev_incorr = \
       utils.get_multiple_struct_fields_mat4py(raw_behavior_summary,
                        ['one', 'two', 'three', 'four', 'correct', 'incorrect',
                         'left', 'right', 'prev_right', 'prev_wrong'])
# Being careful about one-indexing
for i in [one, two, three, four, correct, incorrect, prev_corr, prev_incorr, left, right]:
    i -= 1

# Make subgroup based on class
class0 = np.where(neuron_group.classes == 0)[0]
class1 = np.where(neuron_group.classes == 1)[0]
class2 = np.where(neuron_group.classes == 2)[0]
class0_group = neuron_group.make_subgroup_by_neurons(class0)
class1_group = neuron_group.make_subgroup_by_neurons(class1)
class2_group = neuron_group.make_subgroup_by_neurons(class2)

# Plot activity for each group
plt.figure()
class0_group.plot_all_means(color='b', tvals=np.arange(window[0], window[1] + 1))
class1_group.plot_all_means(color='r', tvals=np.arange(window[0], window[1] + 1))
class2_group.plot_all_means(color='g', tvals=np.arange(window[0], window[1] + 1))

# Compare reward and non-reward
class0_group_corr = class0_group.make_subgroup_by_trials(left)
class0_group_incorr = class0_group.make_subgroup_by_trials(right)
#plt.figure(figsize=(15, 15))
#class0_group_corr.plot_example_neurons()
#class0_group_incorr.plot_example_neurons()
plt.title('Class 0')

#plt.figure(figsize=(15, 15))
class1_group_corr = class1_group.make_subgroup_by_trials(left)
class1_group_incorr = class1_group.make_subgroup_by_trials(right)
#class1_group_corr.plot_example_neurons()
#class1_group_incorr.plot_example_neurons()
plt.title('Class 1')

#plt.figure(figsize=(15, 15))
class2_group_corr = class2_group.make_subgroup_by_trials(left)
class2_group_incorr = class2_group.make_subgroup_by_trials(right)
#class2_group_corr.plot_example_neurons()
#class2_group_incorr.plot_example_neurons()
plt.title('Class 2')

left_mean_act = class1_group_corr.mean_activities
right_mean_act = class1_group_incorr.mean_activities
left_stderr = class1_group_corr.stderr_activities
left_stdev = left_stderr * np.sqrt(class1_group_corr.neurons[0].ntrials)
right_stderr = class1_group_incorr.stderr_activities
right_stdev = right_stderr * np.sqrt(class1_group_incorr.neurons[0].ntrials)

'''
dprime = (left_mean_act - right_mean_act) / np.sqrt(0.5 * (left_stdev ** 2 + right_stdev ** 2))
plt.figure()
for i in range(86):
    plt.subplot(10, 10, i + 1)
    plt.plot(dprime[i, :])
    plt.ylim(-1, 1)
    plt.plot([5, 5], [-1, 1], '--')
'''
