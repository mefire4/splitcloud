// ===== CONFIGURATION =====
const COGNITO_REGION = "eu-west-1";
const COGNITO_CLIENT_ID = "58q9m2lbjoh49a6evfkrp4q6v4";
const API_BASE_URL = "https://cxcufs3dn6.execute-api.eu-west-1.amazonaws.com/default";

let idToken = null;

// ===== CONNEXION =====
async function seConnecter() {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const statusEl = document.getElementById('login-status');

    statusEl.textContent = "Connexion en cours...";

    try {
        const response = await fetch(
            `https://cognito-idp.${COGNITO_REGION}.amazonaws.com/`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-amz-json-1.1',
                    'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth'
                },
                body: JSON.stringify({
                    AuthFlow: 'USER_PASSWORD_AUTH',
                    ClientId: COGNITO_CLIENT_ID,
                    AuthParameters: { USERNAME: email, PASSWORD: password }
                })
            }
        );

        const data = await response.json();

        if (data.AuthenticationResult) {
            idToken = data.AuthenticationResult.IdToken;
            statusEl.textContent = "Connecté !";
            document.getElementById('login-section').style.display = 'none';
            document.getElementById('app-section').style.display = 'block';
        } else {
            statusEl.textContent = "Erreur : " + (data.message || JSON.stringify(data));
        }
    } catch (err) {
        statusEl.textContent = "Erreur de connexion : " + err.message;
    }
}

// ===== CRÉER UN GROUPE =====
async function creerGroupe() {
    const nom = document.getElementById('nouveau-groupe-nom').value;
    const membresTexte = document.getElementById('nouveau-groupe-membres').value;
    const membres = membresTexte.split(',').map(m => m.trim());
    const statusEl = document.getElementById('creer-groupe-status');

    statusEl.textContent = "Création en cours...";

    try {
        const response = await fetch(`${API_BASE_URL}/creer-groupe`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${idToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nom: nom, membres: membres })
        });

        const data = await response.json();

        if (data.groupe_id) {
            statusEl.textContent = `Groupe créé ! ID : ${data.groupe_id}`;
            document.getElementById('groupe-id').value = data.groupe_id;
        } else {
            statusEl.textContent = "Erreur : " + JSON.stringify(data);
        }
    } catch (err) {
        statusEl.textContent = "Erreur : " + err.message;
    }
}

// ===== CHARGER LES DÉPENSES =====
async function chargerDepenses() {
    const groupeId = document.getElementById('groupe-id').value;
    const listeEl = document.getElementById('liste-depenses');
    listeEl.innerHTML = "Chargement...";

    try {
        const response = await fetch(
            `${API_BASE_URL}/lister-depenses?groupe_id=${groupeId}`,
            { headers: { 'Authorization': `Bearer ${idToken}` } }
        );

        const depenses = await response.json();

        if (!Array.isArray(depenses)) {
            listeEl.innerHTML = "Erreur : " + JSON.stringify(depenses);
            return;
        }

        listeEl.innerHTML = "";
        depenses.forEach(dep => {
            const li = document.createElement('li');
            li.textContent = `${dep.payeur} a payé ${dep.montant}€ (${dep.description})`;
            listeEl.appendChild(li);
        });

    } catch (err) {
        listeEl.innerHTML = "Erreur : " + err.message;
    }
}

// ===== AJOUTER UNE DÉPENSE =====
async function ajouterDepense() {
    const groupeId = document.getElementById('groupe-id').value;
    const payeur = document.getElementById('depense-payeur').value;
    const montant = parseFloat(document.getElementById('depense-montant').value);
    const description = document.getElementById('depense-description').value;
    const statusEl = document.getElementById('ajouter-depense-status');

    statusEl.textContent = "Ajout en cours...";

    try {
        const response = await fetch(`${API_BASE_URL}/ajouter-depense`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${idToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                groupe_id: groupeId,
                payeur: payeur,
                montant: montant,
                description: description
            })
        });

        const data = await response.json();
        statusEl.textContent = "Dépense ajoutée !";
        
        // Recharge automatiquement la liste après ajout
        chargerDepenses();

    } catch (err) {
        statusEl.textContent = "Erreur : " + err.message;
    }
}

// ===== CALCULER LES SOLDES =====
async function calculerSoldes() {
    const groupeId = document.getElementById('groupe-id').value;
    const listeEl = document.getElementById('liste-soldes');
    listeEl.innerHTML = "Calcul en cours...";

    try {
        const response = await fetch(
            `${API_BASE_URL}/calculer-soldes?groupe_id=${groupeId}`,
            { headers: { 'Authorization': `Bearer ${idToken}` } }
        );

        const data = await response.json();

        listeEl.innerHTML = "";
        for (const [personne, solde] of Object.entries(data.soldes)) {
            const li = document.createElement('li');
            if (solde > 0) {
                li.textContent = `${personne} doit recevoir ${solde}€`;
            } else if (solde < 0) {
                li.textContent = `${personne} doit payer ${Math.abs(solde)}€`;
            } else {
                li.textContent = `${personne} est à l'équilibre`;
            }
            listeEl.appendChild(li);
        }

    } catch (err) {
        listeEl.innerHTML = "Erreur : " + err.message;
    }
}