function spectrum = pixelFFT(database,binning,sampling,window,modulate_amp,gpu_mode)
[height,width,nFrames] = size(database);
spectrum = zeros(height,width);

for row0 = 1:binning
    for col0 = 1:binning
        % upload database to GPU or CPU
        if (gpu_mode)
            database_batch = gpuArray(database(row0:binning:end,col0:binning:end,:));
        else
            database_batch = database(row0:binning:end,col0:binning:end,:);
        end
        
        % pixel FFT
        database_batch0 = movmean(database_batch,window,3);
        database_batch = database_batch-database_batch0;
        F_batch = abs(fft(database_batch,nFrames,3)/nFrames);
        FF_batch = 2*F_batch(:,:,1:nFrames/2+1);
        [A_batch,f_max_idxs_batch] = max(FF_batch,[],3);
        f_max_batch = (f_max_idxs_batch-1)*(sampling/nFrames);
        spectrum_batch = f_max_batch.*(f_max_batch<sampling/2 & f_max_batch>0 & A_batch>modulate_amp);

        % merge batch 
        if (gpu_mode)
            spectrum(row0:binning:end,col0:binning:end) = gather(spectrum_batch);
        else
            spectrum(row0:binning:end,col0:binning:end) = spectrum_batch;
        end
    end
end
