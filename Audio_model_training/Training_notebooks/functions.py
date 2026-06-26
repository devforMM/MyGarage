import numpy as np
import librosa
def normalize(audio):
    return audio / (np.max(np.abs(audio)) + 1e-8)

def apply_padding(audio):
    max_len=16000*1
    if len(audio)<max_len:
        return  np.pad(audio, (0, max_len - len(audio)))
    else:
        return audio[:max_len]
def random_noise(audio):
    noise=np.random.randn(len(audio))
    return noise*0.02+audio
def modify_frequence(audio):
    while True:
     x = np.random.uniform(-1, 1)
     if x!=0:
         break
    return librosa.effects.pitch_shift(audio,sr=16000,n_steps=x)

def change_speed(audio):
    while True:
     x = np.random.uniform(0.9, 1.1)
     if x!=0:
         break
    return librosa.effects.time_stretch(audio,rate=x)
    
import os
import soundfile as sf
from tqdm import tqdm
import shutil

def augment_data(input_dir, output_dir, target_count):

    for classe in os.listdir(input_dir):
        class_input_path = os.path.join(input_dir, classe)

        for subset in os.listdir(class_input_path):

            if subset == "train":
                current_count = 0

                class_set_input_path = os.path.join(input_dir, classe, subset)
                class_set_output_path = os.path.join(output_dir, classe, subset)

                os.makedirs(class_set_output_path, exist_ok=True)

                for audio_file in tqdm(os.listdir(class_set_input_path),
                                       desc=f"Augmenting {classe}"):

                    if current_count >= target_count:
                        break

                    if not audio_file.endswith(".wav"):
                        continue

                    path = os.path.join(class_set_input_path, audio_file)

                    audio, sr = librosa.load(path, sr=16000)
                    audio = normalize(apply_padding(audio))

                    sf.write(os.path.join(class_set_output_path,
                             f"{current_count}.wav"), audio, sr)

                    current_count += 1

                    if current_count >= target_count:
                        break

                    aug_list = [
                        random_noise(audio),
                        modify_frequence(audio),
                        change_speed(audio),
                        random_noise(modify_frequence(audio))
                    ]

                    for aug in aug_list:

                        if current_count >= target_count:
                            break

                        aug = normalize(apply_padding(aug))

                        sf.write(os.path.join(class_set_output_path,
                                 f"augmented-{current_count}.wav"), aug, sr)

                        current_count += 1

            elif subset == "test":

                class_set_input_path = os.path.join(input_dir, classe, subset)
                class_set_output_path = os.path.join(output_dir, classe, subset)

                os.makedirs(class_set_output_path, exist_ok=True)

                shutil.copytree(class_set_input_path,
                                class_set_output_path,
                                dirs_exist_ok=True)
import random
import shutil
def split_dataset(input_dir, output_dir, test_ratio=0.2):
    os.makedirs(output_dir, exist_ok=True)

    for class_name in os.listdir(input_dir):
        class_path = os.path.join(input_dir, class_name)

        if not os.path.isdir(class_path):
            continue

        files = os.listdir(class_path)
        random.shuffle(files)

        split_idx = int(len(files) * (1 - test_ratio))
        train_files = files[:split_idx]
        test_files = files[split_idx:]

        # folders
        train_class_dir = os.path.join(output_dir,class_name, "train")
        test_class_dir = os.path.join(output_dir,class_name ,"test")

        os.makedirs(train_class_dir, exist_ok=True)
        os.makedirs(test_class_dir, exist_ok=True)

        # copy train
        for f in train_files:
            shutil.copy(
                os.path.join(class_path, f),
                os.path.join(train_class_dir, f)
            )

        # copy test
        for f in test_files:
            shutil.copy(
                os.path.join(class_path, f),
                os.path.join(test_class_dir, f)
            )
            
            

import os
import numpy as np
from tqdm import tqdm
from datasets import Dataset
import librosa

def get_Data(input_dir,feature_extractor):

    train_data_dict = {
        "input_values": [],
        "labels": []
    }

    test_data_dict = {
        "input_values": [],
        "labels": []
    }

    for label, classe in enumerate(sorted(os.listdir(input_dir))):

        class_input_path = os.path.join(input_dir, classe)

        if not os.path.isdir(class_input_path):
            continue

        for subset in os.listdir(class_input_path):

            subset_path = os.path.join(class_input_path, subset)

            if not os.path.isdir(subset_path):
                continue

            for audio_file in tqdm(os.listdir(subset_path),
                                   desc=f"Getting data {classe}"):

                if not audio_file.endswith(".wav"):
                    continue

                path = os.path.join(subset_path, audio_file)

                audio, sr = librosa.load(path, sr=16000)

                processed_audio = feature_extractor(
                    audio,
                    sampling_rate=sr,
                    return_tensors="pt"
                )

                if subset == "train":
                    train_data_dict["input_values"].append(
                        processed_audio["input_values"].squeeze().numpy()
                    )
                    train_data_dict["labels"].append(label)

                elif subset == "test":
                    test_data_dict["input_values"].append(
                        processed_audio["input_values"].squeeze().numpy()
                    )
                    test_data_dict["labels"].append(label)

    # ✅ return à la FIN
    return Dataset.from_dict(train_data_dict), Dataset.from_dict(test_data_dict)