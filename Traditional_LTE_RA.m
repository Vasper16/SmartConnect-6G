clc; clear; close all;

% --- Setup: Sample Data (Realistic collision decay curve) ---
episodes = 1:100;
% Simulated realistic collision reduction: exponential decay with noise
collision_ai = 4.3 * exp(-0.045 * episodes) + 0.2 * randn(1, 100);
collision_ai = max(collision_ai, 0.5);  % Lower bound to simulate real floor

% Traditional vs AI LTE-A metrics (as per images)
collision_traditional = 5;
delay_traditional = 10;
sinr_traditional = 10;

collision_ai_avg = 0.5;
delay_ai = 0.8;
sinr_ai = 15;

% MIMO SINR per antenna
mimo_sinr = [15.2, 17.8, 16.5, 18.1];

% Time-series SINR data (simulated for 3 antennas)
t = 1:100;
sinr_ant1 = 10 + 5 * sin(0.1 * t);
sinr_ant2 = 12 + 4 * cos(0.1 * t);
sinr_ant3 = 11 + 3 * sin(0.1 * t + 1);

% --- Global Settings ---
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesFontWeight', 'bold');

%% 1. AI Training Collision Trend (Line Plot with Labels)
figure;
plot(episodes, collision_ai, '-o', ...
    'LineWidth', 2, 'Color', [0.2 0.6 0.9], ...
    'MarkerSize', 4, 'MarkerFaceColor', [0.2 0.6 0.9]);
grid on;
xlabel('Training Episodes', 'FontWeight', 'bold');
ylabel('Number of Collisions', 'FontWeight', 'bold');
title('Collision Reduction During AI Training', 'FontWeight', 'bold');
xlim([1 100]);
ylim([0.5 5]);

% Annotate start and end
text(3, collision_ai(1) + 0.3, sprintf('Start: %.1f collisions', collision_ai(1)), ...
    'FontSize', 11, 'FontWeight', 'bold');
text(88, 0.55, sprintf('End: %.1f collisions', collision_ai(end)), ...
    'FontSize', 11, 'FontWeight', 'bold');
legend('AI Training Progress', 'Location', 'northeast');

%% 2. Traditional vs AI-Optimized: Grouped Bar Chart
metrics = categorical({'Collisions','Delay (ms)','Avg SINR (dB)'});
metrics = reordercats(metrics, {'Collisions','Delay (ms)','Avg SINR (dB)'});
traditional = [collision_traditional, delay_traditional, sinr_traditional];
ai = [collision_ai_avg, delay_ai, sinr_ai];

figure;
b = bar(metrics, [traditional; ai]', 'grouped');
b(1).FaceColor = [0.7 0.2 0.2]; % Traditional
b(2).FaceColor = [0.2 0.7 0.6]; % AI-Optimized
ylabel('Measured Value', 'FontWeight', 'bold');
title('Performance Comparison: Traditional vs AI-Optimized LTE-A', 'FontWeight', 'bold');
legend({'Traditional LTE-A','AI Optimized'}, 'Location','northeast');

% Add percentage improvements
improvements = round((1 - ai(1:2)./traditional(1:2)) * 100);
text(1, traditional(1) + 0.3, sprintf('%g', traditional(1)), 'HorizontalAlignment','center');
text(1, ai(1) + 0.3, sprintf('%.1f', ai(1)), 'HorizontalAlignment','center');
text(1, traditional(1) + 1.2, sprintf('-%d%%', improvements(1)), 'Color','g', 'FontWeight','bold');

text(2, traditional(2) + 0.5, sprintf('%g', traditional(2)), 'HorizontalAlignment','center');
text(2, ai(2) + 0.3, sprintf('%.1f', ai(2)), 'HorizontalAlignment','center');
text(2, traditional(2) + 1.2, sprintf('-%d%%', improvements(2)), 'Color','g', 'FontWeight','bold');

%% 3. MIMO SINR Per Antenna (Bar Chart with Labels)
figure;
bar(mimo_sinr, 'FaceColor', [0.3 0.6 0.4], 'BarWidth', 0.6);
xlabel('Antenna Index', 'FontWeight', 'bold');
ylabel('SINR (dB)', 'FontWeight', 'bold');
title('Per-Antenna Average SINR', 'FontWeight', 'bold');
ylim([0 max(mimo_sinr)*1.2]);
grid on;

% Annotate bars with SINR values
text(1:length(mimo_sinr), mimo_sinr, ...
    arrayfun(@(v) sprintf('%.1f',v), mimo_sinr, 'UniformOutput', false), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);

%% 4. MIMO SINR Over Time (Line Plot for 3 Antennas)
figure; hold on;
plot(t, sinr_ant1, '-r', 'LineWidth', 2);
plot(t, sinr_ant2, '--b', 'LineWidth', 2);
plot(t, sinr_ant3, ':k', 'LineWidth', 2);
xlabel('Time (samples)', 'FontWeight', 'bold');
ylabel('SINR (dB)', 'FontWeight', 'bold');
title('MIMO SINR Performance Over Time', 'FontWeight', 'bold');
legend({'Antenna 1', 'Antenna 2', 'Antenna 3'}, 'Location', 'best');
grid on;
ylim([min([sinr_ant1 sinr_ant2 sinr_ant3])-5, max([sinr_ant1 sinr_ant2 sinr_ant3])+5]);
